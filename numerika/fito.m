tic

%podatki='kras-e.grd';
podatki='menisija.grd';

if ~exist(strrep(podatki,'.grd','-obj.mat'), 'file') == 2
    extro(podatki);
end

if ~exist(strcat('vrtaca-',podatki), 'file') == 2
    zoomo(podatki);
end

grid=grd_read_v2(strcat('vrtaca-',podatki));

toc