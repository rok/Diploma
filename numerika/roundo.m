%%podatki='/media/user/90A9-8DF8/menisija.grd';
%%grid=grd_read_v2(podatki);
%%load /home/user/diploma/numerika/centri-po-fitu.mat
%
%bb = fix(reshape([s.BoundingBox],4,[]));
%
%for i=1:size(s,1)
    %tmp = grid(bb(2,i):(bb(2,i)+bb(4,i)-1),bb(1,i):(bb(1,i)+bb(3,i)-1));
    %tmp(tmp==0) = mean(tmp(tmp~=0)); % popravek zaradi manjkajocih tock na mejah
    %tmp = tmp - min(min(tmp));
    %%imagesc(tmp);
    %
    %if (s(i).y > 0) && ( s(i).y < size(tmp,1) ) && (s(i).x > 0) && ( s(i).x < size(tmp,2) )
%
    %stevec = zeros(2,sqrt(size(tmp,1)^2+size(tmp,2)^2));
    %
    %for j=1:size(tmp,1)
        %for k=1:size(tmp,2)
            %r = nonzeros(round( sqrt((k-s(i).x)^2 + (j-s(i).y)^2) ));
            %stevec(1,r) = stevec(1,r) + tmp(j,k);
            %stevec(2,r) = stevec(2,r) + 1;
        %end
    %end
    %stevec(1,:)  = stevec(1,:) ./ stevec(2,:);
    %s(i).profil = stevec(1,~isnan(stevec(1,:)));
    %s(i).profilsize = size(s(i).profil,2);
%end
%end
%maxprofil = max([s.profilsize]);
%minprofil = min([s.profilsize]);
%
%%save(strrep(podatki,'.grd','-profili.mat'),'s')
%save('/home/user/diploma/numerika/menisija-profili2.mat','s')

%load /home/user/diploma/numerika/menisija-profili2.mat

for i=1:size(s,1)
    stevec = s(i).profil;
    s(i).profilsize = size(s(i).profil,2);
    s(i).profil = stevec(~isnan(stevec));
end
maxprofil = max([s.profilsize]);
minprofil = min([s.profilsize]);

for i=1:size(s,1)
    s(i).profil = [s(i).profil,zeros(1,maxprofil - s(i).profilsize)];
end

for j=minprofil:maxprofil
    n = 0;
    profi  = zeros(maxprofil,1);
    for i=1:size(s,1)
        if s(i).profilsize == j
            profi = profi + s(i).profil';
            n=n+1;
        end
    end
    plot(profi(1:j)/n);
    pause
end
plot(profi/n);

print menisija-polmeri-hist -depsc2

%save(strrep(podatki,'.grd','-profili.mat'),'s')
%save('/home/user/diploma/numerika/menisija-profili.mat','s')
%load /home/user/diploma/numerika/menisija-profili.mat