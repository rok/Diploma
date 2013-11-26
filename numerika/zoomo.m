function zoomo(podatki)

grid=grd_read_v2(podatki);
grid(grid==1.701410000000000e+038)=0;grid(grid==-1)=0;
load(strrep(podatki,'.grd','-obj.mat'))

% Izracunamo statistiko
s = [regionprops(TPI{2}-1,'Area','BoundingBox'); ...
     regionprops(TPI{1}-1,'Area','BoundingBox'); ...
     regionprops(TPI{3}-1,'Area','BoundingBox')];
% Odstranimo premajhne vrtace
s( find([s.Area] == 0) ) = [];

%%
% Vrtace raztegnemo in zracunamo povprecno obliko

% Izracunamo lokacije izrezov
bb = fix(reshape([s.BoundingBox],4,[]));
r = sqrt([s.Area]/pi);
a = fix(max([bb(3,:),bb(4,:)])+2*max(r));

% Paddamo grid
tgrid = padarray(grid,[round(a/2),round(a/2)]);

% Bounding box-e naredimo kvadratne
bb(1,:) = bb(1,:)+round(a/2);
bb(2,:) = bb(2,:)+round(a/2);
c1 = bb(3,:) < bb(4,:);
c2 = bb(3,:) > bb(4,:);
bb(1,c1) = bb(1,c1) - fix((bb(4,c1)-bb(3,c1))/2);
bb(2,c2) = bb(2,c2) - fix((bb(3,c2)-bb(4,c2))/2);
bb(3,c1) = bb(4,bb(4,:) > bb(3,:));
bb(4,c2) = bb(3,bb(3,:) > bb(4,:));
bb(1,:) = bb(1,:) - r;
bb(2,:) = bb(2,:) - r;
bb(3,:) = bb(3,:) + 2*r;
bb(4,:) = bb(4,:) + 2*r;
bb = fix(bb);

% Manjkajoce podatke nadomestimo s povprecjem v bounding box-u,
% vsem tockam vrtac odstejemo visino minimalne tocke,
% vrtace raztegnemo na velikost najvecje vrtace v mnozici.

Z = zeros(a);
for i=1:size(s,1)
    tmp = tgrid(bb(2,i):(bb(2,i)+bb(4,i)),bb(1,i):(bb(1,i)+bb(3,i)));
    tmp(tmp==0) = mean(tmp(tmp~=0)); % popravek zaradi manjkajocih tock na mejah
    tmp = tmp - min(min(tmp));
    tmp = imresize(tmp, [a a]);
    Z = Z + tmp/size(s,1);
%    subplot(1,2,1);
%    imagesc(Z);
%    subplot(1,2,2);
%    imagesc(tmp);
%    pause
end
imagesc(Z);

%%
grd_write(Z,1,size(Z,1),1,size(Z,2),strcat('vrtaca-',podatki));

end