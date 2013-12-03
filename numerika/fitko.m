% load /home/user/diploma/numerika/menisija-profil-profilov.mat

## independents
indep = 1:5;
## residual function:
p=[1,1,1,1];
%f = @ (p) p(1) + p(2) * exp (((p(3) - 1:size(profi,2))/p(4))^2) - profi(:,j);
f = @ (p) p(1) + p(2) * exp (((p(3) - x)/p(4))^2);
x=0:0.1:10;
  ## initial values:
  init = [.25; .25;1;2];
  ## linear constraints, A.' * parametervector + B >= 0
  A = [1; -1]; B = 0; # p(1) >= p(2);
  settings = optimset ("inequc", {A, B});

  ## start optimization
  [p, residuals, cvg, outp] = nonlin_residmin (f, init, settings)
  
%  ft = fittype('a + b*exp(-((x-c)*d)^2-((y-e)*f)^2) + g*x + h*y', 'indep', {'x', 'y'}, 'depend', 'z' );