function plot_results(data)

load(strrep(data,'.grd','-profiles.mat'))

%%
% Plot histogram of profile size
if 1
    profile_sizes = [s.profilesize];
    
    figure(gcf);
    hist(profile_sizes(profile_sizes~=0),max(profile_sizes))
    title('Porazdelitev konkavnih objektov po efektivnem polmeru')
    xlabel('Efektivni polmer [m]')
    ylabel('N [ ]')
    printpdf(gcf,'../Latex/slike/menisija-polmeri-hist',14.5,8); %'-S750,420'
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
    title('Porazdelitev utezi prislonjenih funkcij')
    xlabel('Utez gaussove funkcije - A [m]')
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
    xlabel('\sigma = (\sigma_x^2 + \sigma_y^2)^{1/2} [m]')
    ylabel('N(\sigma) [ ]')
    printpdf(gcf,'../Latex/slike/menisija-sigme-hist',14.5,8); %'-S750,420'
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
    title(sprintf('Naleganje gaussovke na povprecje profilov vrtac velikosti (r_{eff} = %d m)',j))
    xlabel('Polmer [m]')
    ylabel('Odstopanje modela f(r) [m]')
    legend('f(r) = z_{izmerjen}(r) - A e^{-((r-r_0)/\sigma)^2}','location','southeast')
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
% Plot sigma depending on r and a fit of a linear function
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
    xlabel('Velikost vrtac r_{eff} [m]');
    legend('Izmerjena \sigma',sprintf('Sigma(r_{eff}) = %f * r_{eff} + %f',sigma_fit.k,sigma_fit.const),'location','southeast');
    hold off;
    printpdf(gcf,'../Latex/slike/menisija-sigme',14.5,8);
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