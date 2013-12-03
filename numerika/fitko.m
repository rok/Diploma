load /home/user/diploma/numerika/menisija-profil-profilov.mat

if 1 # Fitting
    ps = zeros(4,60-5);
    for j=5:60
        ## independents and observations
        indep = 0:(size(nonzeros(profi(:,j))',2)-1);
        obs = profi(1:j,j)';
        obs = obs - min(obs);
	
        f = @ (p, x) p(1) *(1 - exp (-(p(2) * (x-p(3))).^2))+p(4);
        ## initial values:
        init = [max(obs); 1; 0;0];
    
        ## start optimization
        [p, model_values, cvg, outp] = nonlin_curvefit (f, init, indep, obs)
        ps(:,j-4) = p;
        if j==22 # plotting
            plot(obs,'linewidth',1,'b','marker','+');
            hold on;
            plot(model_values,'linewidth',2,'r');
            hold off;
            pause
        end
    end
end

if 0
    plot(sqrt(abs(ps(2,3:end))))
end