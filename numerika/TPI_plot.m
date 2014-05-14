%% Concavity index calculation and plot
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
end

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

printpdf(gcf,'../Latex/slike/concavity-samples',20,16); %'-S750,420'
