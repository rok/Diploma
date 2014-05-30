function plot_results(data)

load(strrep(data,'.grd','-profiles.mat'))

%%
% Plot histogram of profile size
if 1
    profile_sizes = [s.profilesize];
    
    figure(gcf);
    profile_sizes = profile_sizes(profile_sizes < 120);
    hist(profile_sizes(profile_sizes~=0),max(profile_sizes)-3)
    title('Porazdelitev konkavnih objektov po efektivnem polmeru')
    xlabel('Efektivni polmer r_{eff} [m]')
    ylabel('N')
    printpdf(gcf,'../Latex/slike/menisija-polmeri-hist',18,5); %'-S750,420'
end

%%
% Plot histogram of fitted As
if 1 
    all_fits = [s.fit];
    A=[all_fits.A];
    A=A(abs(A)<30);
    A=A(A<10);

    figure(gcf);
    hist(A,40)
    title('Porazdelitev utezi prislonjenih Gaussovk')
    xlabel('A [m]')
    ylabel('N(A) [ ]')
    printpdf(gcf,'../Latex/slike/menisija-globine-hist',14.5,6); %'-S750,420'
end

%%
% Plot histogram of fitted sigmas
if 1 
    all_fits = [s.fit];
    sigmas=sqrt([all_fits.sx].^2 + [all_fits.sx].^2);

    figure(gcf);
    hist(sigmas(sigmas<60),60)
    title('Porazdelitev \sigma prislonjenih funkcij')
    xlabel('\sigma [m]')
    ylabel('N(\sigma) [ ]')
    printpdf(gcf,'../Latex/slike/menisija-sigme-hist',14.5,8); %'-S750,420'
end

%%
% Plot histogram of fitted As and sigmas
if 1 
    all_fits = [s.fit];
    sigmas=sqrt([all_fits.sx].^2 + [all_fits.sx].^2);
    A=[all_fits.A];
    A = A(A<0);
    sigmas = sigmas(A<0);
    A = A(sigmas>5);
    sigmas = sigmas(sigmas>1);

    A=A(abs(A)<30);
    A=A(A<10);

    figure(gcf);
    subplot(1,2,1);
    hist(A,40)
    title('Porazdelitev globin A prislonjenih Gaussovk')
    xlabel('A [m]')
    ylabel('N(A)')

    subplot(1,2,2);
    figure(gcf);
    hist(sigmas(sigmas<60),60)
    title('Porazdelitev \sigma prislonjenih funkcij')
    xlabel('\sigma [m]')
    ylabel('N(\sigma)')
    printpdf(gcf,'../Latex/slike/menisija-visine-in-sigme-hist',20,9); %'-S750,420'
end

%%
% Plot one of a chosen average profiles
if 1
    reff = 24; % the profile we want to point out
    
    figure(gcf);
    plot(profiles(reff,1:reff))
    title(sprintf('Profil povprecja objektov z enakim efektivnim polmerom (r_{eff} = %d)',reff))
    xlabel('Polmer [m]')
    ylabel('Visina [m]')
    % printpdf(gcf,'../Latex/slike/menisija-profil-21',16,12); %'-S900,400'
end

%%
% Plot the profile-fit difference

if 1
    j=24;
    
    figure(gcf);
    plot(profiles(j,1:j)'-profile_fits{j}(1:j),'-b+','Color','blue','LineWidth',2);
    ylim ([-0.065,0.05]);
    title(sprintf('Odstopanje Gaussovke od povprecja profilov vrtac velikosti (r_{eff} = %d m)',j))
    xlabel('Polmer r [m]')
    ylabel('Odstopanje modela f(r) [m]')
    legend('f(r) = H(r) - A e^{-((r-r_0)/\sigma)^2 + C}','location','southeast')
    printpdf(gcf,'../Latex/slike/menisija-profil-21-fit',14.5,8); %'-S900,400'
end

%%
% Plot sigma depeding on r
if 1
    sigmas = [];
    for i = 1:size(profile_fits,2)
        try
        sigmas(i) = profile_fits{i}.sigma
        end
    end
    
    figure(gcf);
    plot(sigmas)
    title('Odvisnost sigma_x od r_{eff}')
    ylabel('sigma_x [m]')
    xlabel('Polmer [m]')
    % printpdf(gcf,'../Latex/slike/menisija-sigme',16,12);
end

%%
% Plot sigma depending on r and fit a linear function
if 1
	sigmas = [];
    for i = 1:size(profile_fits,2)
        try
        sigmas(i) = profile_fits{i}.sigma
        end
    end
    
    sf = fittype('k*sigma + const', 'indep', 'sigma');
	init = [min(sigmas); range(sigmas)/length(sigmas)];
    sigma_fit = fit( (1:size(profile_fits,2))', sigmas', sf, 'StartPoint', init)
    
    figure(gcf);
    plot(sigmas);
    hold on;
    plot(sigma_fit);
    title('Odvisnost \sigma(r_{eff})');
    ylabel('\sigma [m]');
    xlabel('r_{eff} [m]');
    legend('Izmerjena \sigma',strcat('\sigma', sprintf('(r_{eff}) = %1.2g * r_{eff} %1.2g',sigma_fit.k,sigma_fit.const)),'location','southeast');
    hold off;
    printpdf(gcf,'../Latex/slike/menisija-sigme',14.5,8);
end

%%
% Plot sigma and A depending on r_eff and fit a linear function
if 1
    data = 'menisija.grd';
    load(strrep(data,'.grd','-profiles.mat'))
    all_fits = [s.fit];
    sigmas=sqrt([all_fits.sx].^2 + [all_fits.sx].^2);
    As = [all_fits.A];
    reffs = [s.profilesize];

    %Remove positive As and too small reffs
    sigmas = sigmas(As<0);
    reffs = reffs(As<0);
    As = As(As<0);
    sigmas = sigmas(reffs>5);
    As = As(reffs>5);
    reffs = reffs(reffs>5);
    As = As(sigmas>1);
    reffs = reffs(sigmas>1);
    sigmas = sigmas(sigmas>1);

    % Cut fits with sigmas more than cutoff value
    cutoff = 60;
    As = As(sigmas<cutoff);
    reffs = reffs(sigmas<cutoff);
    sigmas = sigmas(sigmas<cutoff);
    
    % Fit for A(sigma)
    asfit = fittype('k*as', 'indep', 'as');
    asinit = [-0.5];
    as_fit = fit( 0.4*sigmas', abs(As'), asfit, 'StartPoint', asinit);
    % Fit for sigma(reff)
    srfit = fittype('k*sigmas', 'indep', 'sigmas');
    srinit = [1];
    sr_fit = fit( reffs', sigmas', srfit, 'StartPoint', srinit);
    % Fit for A(reff)
    arfit = fittype('k*reffs', 'indep', 'reffs');
    arinit = [-1];
    ar_fit = fit( reffs', abs(As'), arfit, 'StartPoint', arinit);
    
    figure(gcf);
    subplot(2,2,1)
    scatter(reffs(reffs<cutoff),sigmas(reffs<cutoff),3)
    hold on;
    h1 = plot(sr_fit);
    set(h1,'LineWidth',2);
    ylabel('\sigma [m]');
    xlabel('r_{eff} [m]');
    title('Odvisnost \sigma(r_{eff})');
    legend('Izmerjene \sigma',strcat('\sigma(r_{eff})', sprintf(' = %1.1g',sr_fit.k),'\cdot r_{eff}'),'location','northwest');
    hold off;

    subplot(2,2,2)
    scatter(reffs(reffs<cutoff),abs(As(reffs<cutoff)),3)
    hold on;
    h2 = plot(ar_fit);
    ylim([0,20])
    set(h2,'LineWidth',2);
    ylabel('|A| [m]');
    xlabel('r_{eff} [m]');
    title('Odvisnost |A(r_{eff})|');
    %legend('Izmerjene globine A',strcat('|A(r_{eff})|', sprintf(' = %1.1g',ar_fit.k),'* r_{eff}'),'location','northwest');
    legend('Izmerjene globine |A|',strcat('|A(r_{eff})|', sprintf(' = %1.1g',ar_fit.k),' \cdot r_{eff}'),'location','northwest');
    hold off;
    
    subplot(2,1,2)
    scatter(0.4*sigmas(reffs<cutoff),abs(As(reffs<cutoff)),3)
    hold on;
    h3 = plot(as_fit);
    ylim([0,25])
    set(h3,'LineWidth',2);
    ylabel('|A| [m]');
    xlabel('0,4 \cdot \sigma [m]');
    title('Odvisnost |A(0,4 \cdot \sigma)|');
    legend('Izmerjene globine |A|',strcat('|A(0,4 \cdot \sigma)| = ', sprintf('%1.2g',as_fit.k),' \cdot (0,4 \cdot \sigma)'),'location','northwest');
    hold off;
    
    printpdf(gcf,'../Latex/slike/menisija-A-sigma-reff',25,15);
end
%%

if 1
    sf = fittype('k*sigma + const', 'indep', 'sigma');
    af = fittype('k*A + const', 'indep', 'A');
	sinit = [min(sigmas); range(sigmas)/length(sigmas)];
    ainit = [min(As); range(As)/length(As)];
    sigma_fit = fit( (1:size(profile_fits,2))', sigmas', sf, 'StartPoint', sinit);
    As_fit = fit( (1:size(profile_fits,2))', As', af, 'StartPoint', ainit);
    
    figure(gcf);
    subplot(1,2,1)
    plot(sigmas);
    hold on;
    plot(sigma_fit);
    title('Odvisnost \sigma(r_{eff})');
    ylabel('\sigma [m]');
    xlabel('r_{eff} [m]');
    legend('Izmerjena \sigma',strcat('\sigma', sprintf('(r_{eff}) = %1.2g * r_{eff} %1.2g',sigma_fit.k,sigma_fit.const)),'location','southeast');
    subplot(1,2,2)
    plot(As);
    hold on;
    plot(As_fit);
    title('Odvisnost A(\sigma)');
    ylabel('A [m]');
    xlabel('\sigma [m]');
    legend('Izmerjena globina A',strcat('\sigma', sprintf('(\sigma) = %1.2g * A %1.2g',As_fit.k,As_fit.const)),'location','southeast');
    hold off;
    %printpdf(gcf,'../Latex/slike/menisija-A-od-sigme',14.5,8);
end

%%
% Plot of average profiles side by side, from smallest to biggest ones
if 1
    figure(gcf);
    contour(5:60,5:60,profiles(5:60,5:60)',50)
    title('Visina v odvisnosti od polmera za povprecja vrtac razlicih velikosti')
    xlabel('Efektivni polmer objektov [m]')
    ylabel('Polmer profila  [m]')
    printpdf(gcf,'../Latex/slike/menisija-profil-profilov',14.5,8);
end

end