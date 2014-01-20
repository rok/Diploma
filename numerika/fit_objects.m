function fit_objects(data)

grid=grd_read_v2(data);
grid(grid==1.701410000000000e+038)=0;grid(grid==-1)=0;
load(strrep(data,'.grd','-obj.mat'))

% Calculate statistics of objects
s = [regionprops(TPI{2}-1,'Area','BoundingBox','Image'); ...
     regionprops(TPI{1}-1,'Area','BoundingBox','Image'); ...
     regionprops(TPI{3}-1,'Area','BoundingBox','Image')];
% Remove objects too small
s( find([s.Area] == 0) ) = [];

% Save bounding boxes
bb = fix(reshape([s.BoundingBox],4,[]));

%%
% Missing data is replaced by average of other data within
% bounding box. Values of pixles are set so that minimum points
% are at zero height.

tic; disp 'Fitting ..';
for i=1:size(s,1)
    tmp = grid(bb(2,i):(bb(2,i)+bb(4,i)-1),bb(1,i):(bb(1,i)+bb(3,i)-1));
    tmp(tmp==0) = mean(tmp(tmp~=0)); % Correncting for missing points at borders
    tmp = tmp - min(min(tmp));
    weights = s(i).Image;

    [xInput, yInput, zOutput, weights] = prepareSurfaceData(1:size(tmp,2), 1:size(tmp,1), tmp, double(s(i).Image));
    ft = fittype('a + b*exp(-((x-c)*d)^2-((y-e)*f)^2) + g*x + h*y', 'indep', {'x', 'y'}, 'depend', 'z' );
    opts = fitoptions( ft );
    opts.Display = 'Off';
    opts.Lower = [-Inf -Inf -Inf -Inf -Inf -Inf -Inf -Inf];
    opts.StartPoint = [max(max(tmp)) -4 size(tmp,1)/2 0.05 size(tmp,2)/2 0.05 0.1 0.1];
    opts.Upper = [Inf Inf Inf Inf Inf Inf Inf Inf];
    opts.Weights = weights;
    [fitresult, gof] = fit( [xInput, yInput], zOutput, ft, opts );
    
    s(i).fit = struct(  'h',    fitresult.a, ...
                        'A',    fitresult.b, ...
                        'x0',   fitresult.c, ...
                        'sx', 1/fitresult.d, ...
                        'y0',   fitresult.e, ...
                        'sy', 1/fitresult.f, ...
                        'Cx',   fitresult.g, ...
                        'Cy',   fitresult.h  );

	if 0 % If set to '1' enables debugging plot
        x0 = [size(tmp,2)/2;size(tmp,1)/2];
        x = fsolve(@(x)doline(x,s(i).fit),x0);

        figure(gcf);
        subplot(1,2,1);	
        plot(fitresult,'style','Contour')
        hold on;
        plot(x(1),x(2),'yo','MarkerFaceColor','r');
        hold off;

        subplot(1,2,2);
        imagesc(flipud(tmp));
        hold on;
        plot(x(1),x(2),'yo','MarkerFaceColor','r');
        hold off;
        pause
    end
end
disp 'Fitting ended'; toc;

%%
% Find minimum of fit, declare it center of doline

for i=1:size(s,1)
    x0 = [bb(3,i)/2;bb(4,i)/2];
    x = fsolve(@(x)doline(x,s(i).fit),x0);
    disp(strcat(num2str(i), '/', num2str(size(s,1))));
    s(i).x = x(1);
    s(i).y = x(2);
end

save(strrep(data,'.grd','-fits.mat'), 's')

end