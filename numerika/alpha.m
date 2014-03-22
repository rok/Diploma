%% Measuring roughness exponent

% The input file, ASCII grid file
data='menisija.grd';

%% Import data from .grd file
grid = grd_read_v2(data);
% -1 are borders, 0 are areas without data
grid(grid==1.701410000000000e+038)=0;grid(grid==-1)=0;grid(grid==0)=NaN;


%% Calculate interface width-lenght pairs

w = [nanstd(grid) nanstd(grid')];
L = [sum(~isnan(grid)) sum(~isnan(grid'))];
logw = log(w);
logL = log(L);
logw = logw(logL > 8.5);
logL = logL(logL > 8.5);

%% Fit

logL = logL(:);
logw = logw(:);
ok_ = isfinite(logL) & isfinite(logw);
ft_ = fittype({'x'},'dependent',{'y'},'independent',{'x'},'coefficients',{'a'});
cf_ = fit(logL(ok_),logw(ok_),ft_);

%% Plot

figure(gcf);
hold on;
scatter(logL,logw);
h_ = plot(cf_,'predobs',0.95);
set(h_(1),'Color',[1 0 0],'LineStyle','-', 'LineWidth',2,'Marker','none', 'MarkerSize',6);
dx = 0.03;
xlim([min(logL)-dx, max(logL)+dx]);
title('Merjenje eksponenta hrapavosti \alpha')
xlabel('ln(L)')
ylabel('ln(w_{sat})')
legend(h_,'f(ln L) = \alpha * ln L','95%','location','SouthEast');
hold off;
printpdf(gcf,'../Latex/slike/menisija-alfa',15,8);