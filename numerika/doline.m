function F = doline(x,f)

%gix = @(x,y)((f.Cx*f.sx^2)/(2*f.A) - (x-f.x0)*exp(-((x-f.x0)/f.sx)^2-((y-f.y0)/f.sy)^2));
%giy = @(x,y)((f.Cy*f.sy^2)/(2*f.A) - (y-f.y0)*exp(-((x-f.x0)/f.sx)^2-((y-f.y0)/f.sy)^2));

F = [(f.Cx*f.sx^2)/(2*f.A) - (x(1)-f.x0)*exp(-((x(1)-f.x0)/f.sx)^2-((x(2)-f.y0)/f.sy)^2);
     (f.Cy*f.sy^2)/(2*f.A) - (x(2)-f.y0)*exp(-((x(1)-f.x0)/f.sx)^2-((x(2)-f.y0)/f.sy)^2)];
end