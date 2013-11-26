function extro(podatki)

%% Uvoz podatkov
grid = grd_read_v2(podatki);
% -1 so meje, 0 so prazna obmocja
grid(grid==1.701410000000000e+038)=0;grid(grid==-1)=0;grid(grid==0)=NaN;

% Izracun TPI
krofi = [[10,15];[15,25];[60,100]];
filtri = [5,10,15];
cutoff = -0.5;

for i=1:size(krofi,1)
    TPI{i}=zeros(size(grid));
end
for i=1:size(krofi,1)
    tic;
    % Izracun TPI na wienerovo filtriranem povrsju
    TPI{i} = imfilter(wiener2(grid,[filtri(i) filtri(i)]),ring(krofi(i,1),krofi(i,2)), 'replicate');
%    TPIout{i} = TPI;

    % TPI cutoff
    TPI{i} = - TPI{i} .* (TPI{i} < cutoff*nanstd(nanstd(TPI{i})));
    
    % NaN zamenjamo z 0
    TPI{i}(isnan(TPI{i})) = 0;

    % Odstranimo objekte na mejah
    TPI{i} = imclearborder(TPI{i},4);

    % Oznacimo objekte
    L = bwlabel(TPI{i});

	% Oznacimo centre objektov
    mask_em = imextendedmax(TPI{i}, .8);
    
    % Oznacimo ne-centre objektov
    I_mod = imimposemin(imcomplement(TPI{i}), ~L | mask_em);

    % Objekte segmentiramo z watershed analizo
    TPI{i} = watershed(I_mod);

    % Izmerimo cas
    disp(krofi(i,:));
    toc;
end

% Sprostimo spomin
clearvars 'grid' 'krofi' 'filtri' 'i' 'L' 'mask_em' 'I_mod' 'cutoff';

%% Odstranimo premajhne objekte
TPI{1} = double(TPI{1}) .* bwareaopen(TPI{1}>1,30);
TPI{2} = double(TPI{2}) .* bwareaopen(TPI{2}>1,100);
TPI{3} = double(TPI{3}) .* bwareaopen(TPI{3}>1,5000);

% Odstranimo prevelike objekte
TPI{1} = double(~bwareaopen(TPI{1}>1,500)) .* double(TPI{1}) + 1;
TPI{2} = double(~bwareaopen(TPI{2}>1,10000)) .* double(TPI{2}) + 1;
TPI{3} = double(~bwareaopen(TPI{3}>1,100000)) .* double(TPI{3}) + 1;

%% Izmed kandidatov za vrtace izberemo najbolj primerne, torej:
% Ce objekt v 1 prekriva tocno en objekt iz 2, objekt v 1 izbrisemo
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

% Ce objekt v 2 vsebuje vec kot en objekt iz 1, ga v 2 izbrisemo
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

% Ce objekt v 3 vsebuje vsaj tri objekte iz 1 in 2, ga obdrzimo v 3
overlap123 = [nonzeros(overlap23-1)+1; nonzeros(overlap13-1)+1];
[uniqueEntries,~,idx] = unique(overlap123);
counts = histc(idx,1:max(idx));
overlap123(ismember(overlap123,uniqueEntries(counts<=3))) = [];

TPI{3} = 1 + uint32(double(TPI{3}) .* ismember(TPI{3},overlap123));

% Ce objekt v 3 se vedno vsebuje vec kot en objekt iz 1 ali 2, vrzemo
% te objekte iz 1 in 2 stran
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
disp 'Kandidati za vrtace izbrani';

% Sprostimo spomin
clearvars 'counts' 'idx' 'loc' 'overlap12' 'overlap123' 'overlap13' ...
    'overlap21' 'overlap23' 's' 'uniqueEntries';

%% Shranimo objekte
save(strrep(podatki,'.grd','-obj.mat'),'TPI');

disp 'Objekti shranjeni';

%% Shranimo oblike vrtac, brez oznak
%for i=1:size(obj,2)
%    tic;
%    fname = strrep(podatki,'.grd',strcat('-vrtace-',num2str(i),'-05.grd'));
%    grd_write(obj{i} > 1,xmin,xmax,ymin,ymax,fname);
%    toc;
%end
end