function F = ring( r1, r2 )
  [xx yy] = meshgrid(1:2*r2-1);
  C = sqrt((xx-r2).^2+(yy-r2).^2)<=r1;
  D = sqrt((xx-r2).^2+(yy-r2).^2)<=r2;
  E = sqrt((xx-r2).^2+(yy-r2).^2)<=0;
  F = -double(C - D)/sum(sum(C - D)) + E;
  %imshow(F);
end