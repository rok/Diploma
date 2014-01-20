function extract_objects(data)

%% Import data from .grd file
grid = grd_read_v2(data);
% -1 are borders, 0 are areas without data
grid(grid==1.701410000000000e+038)=0;grid(grid==-1)=0;grid(grid==0)=NaN;

% Calculate concavity
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
%    TPIout{i} = TPI;

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

% Release memory
clearvars 'grid' 'annuli' 'filtres' 'i' 'L' 'mask_em' 'I_mod' 'cutoff';

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

% Release memory
clearvars 'counts' 'idx' 'loc' 'overlap12' 'overlap123' 'overlap13' ...
    'overlap21' 'overlap23' 's' 'uniqueEntries';

%% Save the objects
save(strrep(data,'.grd','-obj.mat'),'TPI');

disp 'Objects saved';

%% Save object shapes, without lables
%for i=1:size(obj,2)
%    tic;
%    fname = strrep(data,'.grd',strcat('-dolines-',num2str(i),'-05.grd'));
%    grd_write(obj{i} > 1,xmin,xmax,ymin,ymax,fname);
%    toc;
%end
end