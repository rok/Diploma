%% Measuring roughness exponent
% The input file, ASCII grid file
data='menisija.grd';
%% Import data from .grd file
grid = grd_read_v2(data);
% -1 are borders, 0 are areas without data
grid(grid==1.701410000000000e+038)=0;grid(grid==-1)=0;grid(grid==0)=NaN;

%% Calculate interface width-lenght pairs
w = [];
l = [];
a = min(size(grid,1),size(grid,2));
b = max(size(grid,1),size(grid,2));
for k=4:50
    for j=1:floor(b/(a/k))
        for i=1:k
            %[i j]
            %floor([(j-1)*a/k+1 j*a/k (i-1)*a/k+1 i*a/k])
            crop = grid(floor((j-1)*a/k+1:j*a/k-1),floor((i-1)*a/k+1:i*a/k));
            tw = std2(crop);
            if ~isnan(tw)
                l = [l a/k];
                w = [w tw];
            end
        end
    end
    k
end
W=[];
L=unique(l);
for i=1:length(unique(L))
    W(i)=mean(w(l==L(i)));
end

%% Fit & plot
logL = log(L)';
logW = log(W)';
f = fittype('k*x + const', 'indep', 'x');
init = [min(logW); range(logW)/range(logL)];
cf_ = fit( logL, logW, f, 'StartPoint', init)

%logl = log(l)';
%logw = log(w)';
%f2 = fittype('k*x + const', 'indep', 'x');
%init2 = [min(logw); range(logw)/range(logl)];
%cf2_ = fit( logl, logw, f2, 'StartPoint', init2);

figure(gcf)
subplot(1,2,1);
scatter(log(l),log(w),3);
hold on;
%plot(cf2_);
title('Hrapavost povrsja ln w(ln(L^2))')
xlabel('ln(L^2)')
ylabel('ln(w_{sat})')
hold off;

subplot(1,2,2);
scatter(log(L),log(W));
hold on;
h = plot(cf_);
set(h,'LineWidth',2);
title('Povprecna hrapavost povrsja ln<w(ln(L^2))>')
xlabel('ln(<L^2>)')
ylabel('ln(<w_{sat}(ln L^2)>)')
legend('ln <w_{sat}(ln(L^2))>',strcat('f(ln(L^2)) = ',sprintf(' %1.2g',cf_.k),' * ln(L^2) ',sprintf(' %1.1g',cf_.const)),'location','SouthEast');
%legend(strcat('A(\sigma)', sprintf(' = %1.1g',as_fit.k),'* \sigma'),'location','southwest');
hold off;

printpdf(gcf,'../Latex/slike/menisija-alfa-3d',25,10);