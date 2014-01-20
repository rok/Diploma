podatki='menisija.grd';
grid=grd_read_v2(podatki);
%load menisija-fiti2.mat

<<<<<<< HEAD
%save('/home/user/diploma/numerika/menisija-profil-profilov.mat','profi')
podatki='/home/rok/Diploma/numerika/menisija.grd';
=======
bb = fix(reshape([s.BoundingBox],4,[]));

for i=1:size(s,1)
    tmp = grid(bb(2,i):(bb(2,i)+bb(4,i)-1),bb(1,i):(bb(1,i)+bb(3,i)-1));
    tmp(tmp==0) = mean(tmp(tmp~=0)); % popravek zaradi manjkajocih tock na mejah
    tmp = tmp - min(min(tmp));
    %imagesc(tmp);
    
    if (s(i).y > 0) && ( s(i).y < size(tmp,1) ) && (s(i).x > 0) && ( s(i).x < size(tmp,2) )

    stevec = zeros(2,sqrt(size(tmp,1)^2+size(tmp,2)^2));
    
    for j=1:size(tmp,1)
        for k=1:size(tmp,2)
            r = nonzeros(round( sqrt((k-s(i).x)^2 + (j-s(i).y)^2) ));
            stevec(1,r) = stevec(1,r) + tmp(j,k);
            stevec(2,r) = stevec(2,r) + 1;
        end
    end
    stevec(1,:)  = stevec(1,:) ./ stevec(2,:);
    s(i).profil = stevec(1,~isnan(stevec(1,:)));
    s(i).profilsize = size(s(i).profil,2);
end
end
maxprofil = max([s.profilsize]);
minprofil = min([s.profilsize]);

save(strrep(podatki,'.grd','-profili.mat'),'s')

%%

load(strrep(podatki,'.grd','-profili.mat'))

maxprofil = max([s.profilsize]);
profi  = zeros(maxprofil);
n = zeros(maxprofil,1);

for j=1:maxprofil
    n(j) = sum([s.profilsize] == j);
end
n(n==0)=1;

for i=5:size(s,1)
    s(i).profil = [s(i).profil,zeros(1,maxprofil - s(i).profilsize)];
    if s(i).profilsize > 0
        profi(:,s(i).profilsize) = profi(:,s(i).profilsize) + s(i).profil(:) / n(s(i).profilsize);
    end
end

save(strrep(podatki,'.grd','-profil-profilov.mat'),'profi','s')

%%
>>>>>>> edc2f95ff49fadd7ba9e016cf1a32d95c22d0afe
load(strrep(podatki,'.grd','-profil-profilov.mat'))

if 0 % Plot histograma efektivnih velikosti
    hist([s.profilsize],max([s.profilsize]))
    title('Porazdelitev konkavnih objektov po efektivnem polmeru')
    xlabel('Efektivni polmer [m]')
    ylabel('N [ ]')
    print ../Latex/slike/menisija-polmeri-hist.eps -depsc "-S750,420"
end

if 1 % Plot histograma utezi za globino A
    B=zeros(1, size(s,1));
    for i=1:size(s,1)
        try
        B(1,i)=s(i).profilsize;
        end
    end
    A = (B>0) .* [[s(:).fit].A];
    A=abs(A(A!=0));
    A=A(A<30);
    A=A(A>1);
    hist(A,30)
    title('Porazdelitev utezi prislonjenih funkcij')
    xlabel('Utez gaussove funkcije - A [m]')
    ylabel('N(A) [ ]')
    print ../Latex/slike/menisija-globine-hist.eps -depsc "-S750,420"
end

if 0 % Plot enega od povprecnih profilov vrtac
    plot(nonzeros(profi(:,21)))
    title('Profil povprecja objektov z enakim efektivnim polmerom (r_{eff} = 21m)')
    xlabel('Polmer [m]')
    ylabel('Visina [m]')
    print ../Latex/slike/menisija-profil-21.eps -depsc "-S900,400"
end

if 0 % Plot povprecnih profilov vrtac razlicnih velikosti
    contour(5:60,5:60,profi(5:60,5:60),50)
    title('Visina v odvisnosti od polmera za povprecja vrtac razlicih velikosti')
    xlabel('Efektivni polmer objektov [m]')
    ylabel('Polmer profila  [m]')
    print ../Latex/slike/menisija-profil-profilov.eps -depsc "-S900,500"
end

%save(strrep(podatki,'.grd','-profili.mat'),'s')
%save('/home/user/diploma/numerika/menisija-profili.mat','s')
%load /home/user/diploma/numerika/menisija-profili.mat