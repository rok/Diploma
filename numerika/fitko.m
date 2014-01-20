load /home/rok/Diploma/numerika/menisija-profil-profilov.mat

if 1 # Fitting
    ps = zeros(4,60-5);
    for j=5:60
        ## independents and observations
        indep = 0:(size(nonzeros(profi(:,j))',2)-1);
        obs = profi(1:j,j)';
        obs = obs - min(obs);
	
        f = @ (p, x) p(1) *(1 - exp (-((x-p(3))/p(2)).^2))+p(4);
        ## initial values:
        init = [max(obs); 1; 0;0];
    
        ## start optimization
        [p, model_values, cvg, outp] = nonlin_curvefit (f, init, indep, obs)
        ps(:,j-4) = p;
        if 0 %  j==22 # plotting
            plot(obs,'linewidth',1,'b','marker','+');
            hold on;
            plot(model_values,'linewidth',2,'r');
            hold off;
            title('Naleganje gaussovke na povprecje profilov (r_{eff} = 21m)')
            xlabel('Polmer [m]')
            ylabel('Visina [m]')
            legend('Povprecni profil','Nalozena funkcija','location','southeast')
            print ../Latex/slike/menisija-profil-21-fit.eps -depsc "-S900,400"
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
            print ../Latex/slike/menisija-profil-21-fit.eps -depsc "-S900,400"
            pause
        end
    end
end

if 0
    plot(3:size(ps,2),sqrt(abs(ps(2,3:end))))
    title('Odvisnost sigma_x od r_{eff}')
    ylabel('sigma_x [m]')
    xlabel('Polmer [m]')
    print ../Latex/slike/menisija-sigme.eps -depsc "-S900,500"
end

if 1 # Plot sigma od r + fit
    ## independents and observations
    indep = 0:(size(ps,2)-3);
    obs = sqrt(abs(ps(2,3:end)));
	
    %f = @ (p, x) p(1) *exp (-(p(2) * (x-p(3)))) + p(4);
    f = @ (p, x) p(1) * x + p(2);
    ## initial values:
    init = [max(obs);0.1;0;0.1];
    
    ## start optimization
    [p, model_values, cvg, outp] = nonlin_curvefit (f, init, indep, obs)

    plot(3:size(ps,2),model_values,'linewidth',2,'r');
    ylim ([0,16])
    hold on;
    plot(3:size(ps,2),sqrt(abs(ps(2,3:end))));
    title('Odvisnost sigma od r_{eff}');
    ylabel('Sigma [m]');
    xlabel('Polmer r_{eff} [m]');
    legend('      Sigma(r_{eff}) = 0,158 * r_{eff} + 1,55}','Izmerjena sigma','location','southeast');
    print ../Latex/slike/menisija-sigme.eps -depsc "-S900,500";
    hold off;
end