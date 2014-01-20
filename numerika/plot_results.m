function plot_results(data)

data='menisija.grd';
load(strrep(data,'.grd','-profiles.mat'))
reff = 22; % the profile we want to point out
    
%%
% Plot histogram of effective size
if 1
    hist([s.profilesize],max([s.profilesize]))
    title('Porazdelitev konkavnih objektov po efektivnem polmeru')
    xlabel('Efektivni polmer [m]')
    ylabel('N [ ]')
    print( '../Latex/slike/menisija-polmeri-hist.eps', '-depsc') %'-S750,420' 
end

%%
% Plot histogram of fitted A
if 1 
    B=zeros(1, size(s,1));
    for i=1:size(s,1)
        try
        B(1,i)=s(i).profilesize;
        end
    end
    fit = [s.fit];
    A = (B>0) .* [fit.A];
    A=abs(A(A~=0));
    A=A(A<30);
    A=A(A>0);
    
    hist(A,30)
    title('Porazdelitev utezi prislonjenih funkcij')
    xlabel('Utez gaussove funkcije - A [m]')
    ylabel('N(A) [ ]')
    print( '../Latex/slike/menisija-globine-hist.eps', '-depsc' ) %'-S750,420' 
end

%%
% Plot one of the average profiles
if 1
    objects = [s([s.profilesize] == reff)];
    tmp = 0;
    for i=1:size(objects,1)
        tmp = tmp + objects(i).profile;
    end
    plot(tmp/size(objects,1))
    
    title(sprintf('Profil povprecja objektov z enakim efektivnim polmerom (r_{eff} = %d)',reff))
    xlabel('Polmer [m]')
    ylabel('Visina [m]')
    print( '../Latex/slike/menisija-profil-21.eps', '-depsc') %'-S900,400' 
end

%%
% Fitting
if 1
    ps = zeros(4,60-5);
    for j=5:60
        % independents and observations
        indep = 0:(size(nonzeros(profi(:,j))',2)-1);
        obs = profi(1:j,j)';
        obs = obs - min(obs);
	
        f = @ (p, x) p(1) *(1 - exp (-((x-p(3))/p(2)).^2))+p(4);
        %% initial values:
        init = [max(obs); 5; 0;0]; 
    
        % start optimization
        [p, model_values, cvg, outp] = nonlin_curvefit (f, init, indep, obs)
        ps(:,j-4) = p;

        if j==22 % plotting
            plot(obs,'linewidth',1,'b','marker','+');
            hold on;
            plot(model_values,'linewidth',2,'r');
            hold off;
            title('Naleganje gaussovke na povprecje profilov (r_{eff} = 21m)')
            xlabel('Polmer [m]')
            ylabel('Visina [m]')
            legend('Povprecni profil','Nalozena funkcija','location','southeast')
            %print( '../Latex/slike/menisija-profil-21-fit.eps', '-depsc', '-S900,400' )
            pause
        end
        
        if 0 % j==22 # plotting
            tmpo = obs - model_values;
            plot(tmpo,'linewidth',2,'b','marker','+');
            ylim ([-0.065,0.05])
            title('Naleganje gaussovke na povprecje profilov (r_{eff} = 21m)')
            xlabel('Polmer [m]')
            ylabel('Odstopanje modela f(r) [m]')
            legend('f(r) = z_{izmerjen}(r) - A e^{-(r-r_0)^2/(sigma)}','location','southeast')
            print( '../Latex/slike/menisija-profil-21-fit.eps', '-depsc', '-S900,400' )
            pause
        end
    end
end

%%
% Plot sigma depeding on r
if 0
    plot(3:size(ps,2),sqrt(abs(ps(2,3:end))))
    title('Odvisnost sigma_x od r_{eff}')
    ylabel('sigma_x [m]')
    xlabel('Polmer [m]')
    print( '../Latex/slike/menisija-sigme.eps', '-depsc', '-S900,500')
end

%%
% Plot sigma depending on r + fit a linear function
if 0
    % independents and observations
    indep = 0:(size(ps,2)-3);
    obs = sqrt(abs(ps(2,3:end)));
    %f = @ (p, x) p(1) *exp (-(p(2) * (x-p(3)))) + p(4);
    f = @ (p, x) p(1) * x + p(2);
    % initial values:
    init = [max(obs);0.1;0;0.1];
    
    % start optimization
    [p, model_values, cvg, outp] = nonlin_curvefit (f, init, indep, obs)

    plot(3:size(ps,2),model_values,'linewidth',2,'r');
    ylim ([0,16])
    hold on;
    plot(3:size(ps,2),sqrt(abs(ps(2,3:end))));
    title('Odvisnost sigma od r_{eff}');
    ylabel('Sigma [m]');
    xlabel('Polmer r_{eff} [m]');
    legend('      Sigma(r_{eff}) = 0,158 * r_{eff} + 1,55}','Izmerjena sigma','location','southeast');
    print( '../Latex/slike/menisija-sigme.eps', '-depsc', '-S900,500');
    hold off;
end


%%
% Plot of average profiles side by side, from smallest to biggest ones
if 1
    maxprofile = max([s.profilesize]);
    minprofile = min([s.profilesize]);
    profiles  = zeros(maxprofile);
    n = zeros(maxprofile,1);
    
    for j=1:maxprofile
        n(j) = sum([s.profilesize] == j);
    end
    n(n==0)=1;
    
    for i=5:size(s,1)
        s(i).profile = [s(i).profile,zeros(1,maxprofile - s(i).profilesize)];
        if s(i).profilesize > 0
            profiles(:,s(i).profilesize) = profiles(:,s(i).profilesize) + s(i).profile(:) / n(s(i).profilesize);
        end
    end
    
    contour(5:60,5:60,profiles(5:60,5:60),50)
    title('Visina v odvisnosti od polmera za povprecja vrtac razlicih velikosti')
    xlabel('Efektivni polmer objektov [m]')
    ylabel('Polmer profila  [m]')
    print('../Latex/slike/menisija-profil-profilov.eps', '-depsc');
end

end