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

tic; disp 'Fitting round one ..';
for i=1:size(s,1)
    tmp = grid(bb(2,i):(bb(2,i)+bb(4,i)-1),bb(1,i):(bb(1,i)+bb(3,i)-1));
    tmp(tmp==0) = mean(tmp(tmp~=0)); % Correncting for missing points at borders
    tmp = tmp - min(min(tmp));
    weights = s(i).Image;

    [xInput, yInput, zOutput, weights] = prepareSurfaceData(1:size(tmp,2), 1:size(tmp,1), tmp, double(s(i).Image));
    ft = fittype('a + b*exp(-((x-c)*d)^2-((y-e)*f)^2) + g*x + h*y', 'indep', {'x', 'y'}, 'depend', 'z' );
    opts = fitoptions( ft );
    opts.Display = 'Off';
    opts.StartPoint= [max(max(tmp)) -range(tmp(:))     size(tmp,1)/2 18/size(tmp,1)    size(tmp,2)/2 18/size(tmp,2)  0.01 0.01];
    opts.Lower = [-10*max(max(tmp)) -5*range(tmp(:))  -size(tmp,1)   0                -size(tmp,2)/2 0              -10  -10];
    opts.Upper = [ 10*max(max(tmp))  range(tmp(:))/5 2*size(tmp,1)   100/size(tmp,1) 2*size(tmp,2)   100/size(tmp,1) 10   10];
    opts.Weights = weights;
    [fitresult, gof] = fit( [xInput, yInput], zOutput, ft, opts );
    
    disp(strcat('Fitting: ', num2str(i), '/', num2str(size(s,1))));
    
    s(i).fit = struct(  'h',    fitresult.a, ...
                        'A',    fitresult.b, ...
                        'x0',   fitresult.c, ...
                        'sx', 1/fitresult.d, ...
                        'y0',   fitresult.e, ...
                        'sy', 1/fitresult.f, ...
                        'Cx',   fitresult.g, ...
                        'Cy',   fitresult.h  );

	if 1 % If set to '1' enables debugging plot
        tfit=s(i).fit;
        doline = @(x) tfit.h + tfit.A*exp(-((tfit.x0-x(1))/tfit.sx)^2-((tfit.y0-x(2))/tfit.sy)^2) + tfit.Cx*x(1) + tfit.Cy*x(2);
        x = fminsearch(doline,[size(tmp,1)/2;size(tmp,2)/2]);
        
        figure(gcf);
        subplot(1,2,1);	
        plot(fitresult,'style','Contour')
        hold on;
        plot(x(1),x(2),'yo','MarkerFaceColor','r');
        hold off;

        subplot(1,2,2);
        imagesc(tmp);
        hold on;
        plot(x(1),x(2),'yo','MarkerFaceColor','r');
        hold off;
        pause
    end
end
disp 'Fitting ended'; toc;

%%
% Find minimum of fit, declare it center of doline

disp 'Fitting round two ..';
for i=1:size(s,1)
	tfit=s(i).fit;
	doline = @(x) tfit.h + tfit.A*exp(-((tfit.x0-x(1))/tfit.sx)^2-((tfit.y0-x(2))/tfit.sy)^2) + tfit.Cx*x(1) + tfit.Cy*x(2);
	x = fminsearch(doline,[bb(3,i)/2;bb(4,i)/2]);
    disp(strcat('Fitting: ', num2str(i), '/', num2str(size(s,1))));
    s(i).x = x(1);
    s(i).y = x(2);
end

%%
save(strrep(data,'.grd','-fits.mat'), 's')

end