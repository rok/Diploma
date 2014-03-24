%% Simulation of Karda-Parisi-Zhang process

%% Simulate
N = 100;
Z = randn(N);
dt = 0.001; % lenght of time step
T = 100000; % number of time steps
ZT = zeros(N,T);

for i=1:T
    Z = Z + (.5 * del2(Z) - randn(N) .* Z) * dt;
    if (rem(i,100) == 0 && 0)
        mesh(-Z(15:end-14,15:end-15));
        pause;
    end
end

%% Plot

A=Z;
A(A<-.3)=0;
A(A>0.4)=0;
%surf(A(1:end,1:end));
%pause
%cutoff=12;
A = A(cutoff+1:end-cutoff,cutoff+1:end-cutoff);
%surf(A);
%pause
%
figure(gcf);
colormap jet
%surf(-log(A+abs(min(min(A)))+1),'EdgeColor','none')
surf(-log(A+abs(min(min(A)))+1),'LineWidth',0.001)
view([-45 75])

printpdf(gcf,'../Latex/slike/KPZ-numericno',14.5,12);