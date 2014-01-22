%% Doline recognition and anlysis script

% The input file, ASCII grid file
data='menisija.grd';

%% Identify concave objects
if ~exist(strrep(data,'.grd','-obj.mat'), 'file') == 1
    extract_objects(data)
end

%% Fit gaussian surfaces onto objecsts
if ~exist(strrep(data,'.grd','-fits.mat'), 'file') == 1
    fit_objects(data)
end

%% Calculate average profiles of objects
if ~exist(strrep(data,'.grd','-profiles.mat'), 'file') == 1
    calculate_profiles(data)
end

%% Plot results
if 1
    plot_results(data)
end

%% Average found dolines
if ~exist(strrep(data,'.grd','-average-doline.grd'), 'file') == 1
    average_dolines(data);
end