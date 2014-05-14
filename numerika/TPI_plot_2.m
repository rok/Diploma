%% Concavity index calculation, segmentation and plot
% The input file, ASCII grid file
data='menisija.grd';

% Import data from .grd file
grid = grd_read_v2(data);

% Crop data 
grid = grid(2100:2700,4100:4700);

%% Calculate concavity
annuli = [[10,15];[15,25];[60,100]];
filtres = [5,10,15];
cutoff = -0.5;

for i=1:size(annuli,1)
    TPI{i}=zeros(size(grid));
end
for i=1:size(annuli,1)
    tic;
    % Calculate concavity index after applying wiener filter
    TPI{i} = imfilter(wiener2(grid,[filtres(i) filtres(i)]),ring(annuli(i,1),annuli(i,2)), 'replicate');

    % TPI cutoff
    TPI{i} = - TPI{i} .* (TPI{i} < cutoff*nanstd(nanstd(TPI{i})));
    
    % Replace NaN with 0
    TPI{i}(isnan(TPI{i})) = 0;

    % Remove objects on borders
    TPI{i} = imclearborder(TPI{i},4);

    % Label objects
    L = bwlabel(TPI{i});

	% Mark centers of objects
    mask_em = imextendedmax(TPI{i}, .8);
    
    % Mark non-centers of objects
    I_mod = imimposemin(imcomplement(TPI{i}), ~L | mask_em);

    % Segment objects with wateshed analysis
    TPI{i} = watershed(I_mod);

    % Mark time
    disp(annuli(i,:));
    toc;
end

%% Remove objects that are too small
TPI{1} = double(TPI{1}) .* bwareaopen(TPI{1}>1,30);
TPI{2} = double(TPI{2}) .* bwareaopen(TPI{2}>1,100);
TPI{3} = double(TPI{3}) .* bwareaopen(TPI{3}>1,5000);

% Remove objects that are too big
TPI{1} = double(~bwareaopen(TPI{1}>1,500)) .* double(TPI{1}) + 1;
TPI{2} = double(~bwareaopen(TPI{2}>1,10000)) .* double(TPI{2}) + 1;
TPI{3} = double(~bwareaopen(TPI{3}>1,100000)) .* double(TPI{3}) + 1;

%% Choose most possible candidates, so:
% If object from layer 1 intersects exactly one object from layer 2,
% object from layer 1 will be removed

tic;
s = regionprops(TPI{2},'Centroid');
loc = int32(reshape([s.Centroid],2,[]));
loc = sub2ind(size(TPI{1}),nonzeros(loc(2,:)),nonzeros(loc(1,:)));
overlap21 = TPI{1}(loc);
overlap23 = TPI{3}(loc);
overlap21 = nonzeros(overlap21-1)+1;
[uniqueEntries,~,idx] = unique(overlap21);
counts = histc(idx,1:max(idx));
overlap21(ismember(overlap21,uniqueEntries(counts~=1))) = [];

TPI{1} = uint32(TPI{1}) - uint32(ismember(TPI{1},overlap21) .* double(TPI{1}));

% If object from layer 2 contains more then one object from layer 1,
% object in layer 2 is deleted
s = regionprops(TPI{2},'Centroid');
loc = int32(reshape([s.Centroid],2,[]));
loc = sub2ind(size(TPI{1}),nonzeros(loc(2,:)),nonzeros(loc(1,:)));
overlap12 = TPI{2}(loc);
overlap13 = TPI{3}(loc);
overlap12 = nonzeros(overlap12-1)+1;
[uniqueEntries,~,idx] = unique(overlap12);
counts = histc(idx,1:max(idx));
overlap12(ismember(overlap12,uniqueEntries(counts<=1))) = [];

TPI{2} = uint32(TPI{2}) - uint32(ismember(TPI{2},overlap12) .* double(TPI{2}));

% If object in layer 3 includes at least 3 objects from layers
% 1 and 3, it is not deleted
overlap123 = [nonzeros(overlap23-1)+1; nonzeros(overlap13-1)+1];
[uniqueEntries,~,idx] = unique(overlap123);
counts = histc(idx,1:max(idx));
overlap123(ismember(overlap123,uniqueEntries(counts<=3))) = [];

TPI{3} = 1 + uint32(double(TPI{3}) .* ismember(TPI{3},overlap123));

% If object from layer 3 includes more then one object from layers
% 1 and 2, we remove those objects
s  = regionprops(TPI{1},'Centroid');
loc = int32(reshape([s.Centroid],2,[]));
loc = sub2ind(size(TPI{1}),nonzeros(loc(2,:)),nonzeros(loc(1,:)));
overlap13 = uint32(TPI{3}(loc) ~= 1) .* TPI{1}(loc);
overlap13 = nonzeros(nonzeros(overlap13)-1)+1;

TPI{1} = TPI{1} - uint32(ismember(TPI{1},overlap13) .* double(TPI{1}));

s  = regionprops(TPI{2},'Centroid');
loc = int32(reshape([s.Centroid],2,[]));
loc = sub2ind(size(TPI{1}),nonzeros(loc(2,:)),nonzeros(loc(1,:)));
overlap23 = uint32(TPI{3}(loc) ~= 1) .* TPI{2}(loc);
overlap23 = nonzeros(nonzeros(overlap23)-1)+1;

TPI{2} = TPI{2} - uint32(ismember(TPI{2},overlap23) .* double(TPI{2}));
toc;
disp 'Candidates for dolines were chosen';

%% Save object shapes, without lables into 3 .grd files for Surfer plot
for i=1:size(TPI,2)
    tic;
    fname = strcat('TPI_plot_',num2str(i),'.grd');
    grd_write(TPI{i} > 1,1,size(grid,1),1,size(grid,2),fname);
    toc;
end

grd_write(grid,1,size(grid,1),1,size(grid,2),'TPI_plot.grd');

%% Plot
figure(gcf);
colormap bone;
subplot(2,2,1);
imagesc(grid);
title('Originalen relief')
xlabel('x [m]')
ylabel('y [m]')
subplot(2,2,2);
imagesc(TPI{1});
title('Kolobar dimenzij r_1=10, r_2=15')
xlabel('x [m]')
ylabel('y [m]')
subplot(2,2,3);
imagesc(TPI{2});
title('Kolobar dimenzij r_1=15, r_2=25')
xlabel('x [m]')
ylabel('y [m]')
subplot(2,2,4);
imagesc(TPI{3});
title('Kolobar dimenzij r_1=60, r_2=100')
xlabel('x [m]')
ylabel('y [m]')

printpdf(gcf,'../Latex/slike/concavity-segmentation-samples',20,16); %'-S750,420'