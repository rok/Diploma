function  calculate_profiles(data)
grid=grd_read_v2(data);
load(strrep(data,'.grd','-fits.mat'))
bb = fix(reshape([s.BoundingBox],4,[]));

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

save(strrep(data,'.grd','-profiles.mat'),'s')
end