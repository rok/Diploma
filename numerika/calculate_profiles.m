function  calculate_profiles(data)
grid=grd_read_v2(data);
load(strrep(data,'.grd','-fits.mat'))
bb = fix(reshape([s.BoundingBox],4,[]));

%%
% Calculate profile of each doline

for i=1:size(s,1)
    tmp = grid(bb(2,i):(bb(2,i)+bb(4,i)-1),bb(1,i):(bb(1,i)+bb(3,i)-1));
    tmp(tmp==0) = mean(tmp(tmp~=0)); % Correncting for missing points at borders
    tmp = tmp - min(min(tmp));
    
    if (s(i).y > 0) && ( s(i).y < size(tmp,1) ) && (s(i).x > 0) && ( s(i).x < size(tmp,2) )
        counter = zeros(2,round(sqrt(size(tmp,1)^2+size(tmp,2)^2)));
        
        for j=1:size(tmp,1)
            for k=1:size(tmp,2)
                r = nonzeros(round( sqrt((k-s(i).x)^2 + (j-s(i).y)^2) ));
                counter(1,r) = counter(1,r) + tmp(j,k);
                counter(2,r) = counter(2,r) + 1;
            end
        end
        counter(1,:)  = counter(1,:) ./ counter(2,:);
        s(i).profile = counter(1,~isnan(counter(1,:)));
        s(i).profilesize = size(s(i).profile,2);
    else
        s(i).profilesize = 0;
    end
end

%%
% Calculate average profiles, for profiles of each size

minprofile = min(nonzeros([s.profilesize]));
maxprofile = max([s.profilesize]);
profiles = zeros(maxprofile);

for j=1:length(profiles)
    profile = [s([s.profilesize] == j)];
    
    for i=1:size(profile,1)
        profiles(j,:) = profiles(j,:) + [profile(i).profile,zeros(1,maxprofile-j)];
    end
    profiles(j,:) = profiles(j,:)/size(profile,1);
end

%%
% Fit 2D gaussian function to profiles
for j=5:60
    profiles(isnan(profiles))=0;
    f = fittype('A * exp(-((x-x0)/sigma).^2) + const', 'indep', 'x');
    init = [min(-profiles(j,:)); 1; j/4;-0.1];
    profile_fits{j} = fit( (1:j)', profiles(j,1:j)', f, 'StartPoint', init);
end

save(strrep(data,'.grd','-profiles.mat'),'s','profiles','minprofile','maxprofile','profile_fits')
end