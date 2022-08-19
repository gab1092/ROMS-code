
cd '/media/gabriela/WDBlue_2/Modelo_NGC/DATOS_MODELOFISICO'
clear all

anioinicial=input('Año inicial: ');
aniofinal=input('Año final: ');


disp(strcat('Iniciando interpolacion de datos para modelo años: ',num2str(anioinicial),'-',num2str(aniofinal)))
% 
% time=ncread(Netcdf,'time');
% dn1950=datenum(1950,1,1)   % baseline point in Matlab datenum
% datestr(dn1950+time/24)

Archivo1=1;
Archivo2=12;  %%numero de meses, archivos por anio


addpath ('/media/gabriela/DATOS_RESENDIZ1/MODELO_ALTOGOLFO')

angle=ncread('ROMS_ETOPO1_Regional.nc','angle');
lon_rho=ncread('ROMS_ETOPO1_Regional.nc','lon_rho');
lat_rho=ncread('ROMS_ETOPO1_Regional.nc','lat_rho');
mask_rho=ncread('ROMS_ETOPO1_Regional.nc','mask_rho');
I=find(mask_rho==0);mask_rho(I)=NaN;clear I

%%Datos del modelo global
anioo1=strcat(num2str(anioinicial),'*');
S1 = dir(anioo1);
N1 = {S1.name};
Netcdf1=char(N1(1));

hg=ncread(Netcdf1,'depth');
lon=ncread(Netcdf1,'longitude');
lat=ncread(Netcdf1,'latitude');

clear S1 N1 anioo1
% lon=lon';
% lat=lat;
%%Vamos a buscar los indices para recortar los datos del global a un area
%%mas acorde con el local

Ix=find(lon>=-115 & lon<=-112.5);
Iy=find(lat>=29 & lat<=32);

[lon1,lat1]=meshgrid(lon(Ix),lat(Iy));
lon1=lon1'; lat1=lat1';

for contii=anioinicial:aniofinal
    
    anioo=strcat(num2str(contii),'*');
    
    S = dir(anioo);
    N = {S.name};
    Netcdf=char(N(1));




%for conti=2013:2021

% aux=strcat(num2str(conti),'*')
% S = dir(aux);
% N = {S.name};
% Netcdf=char(N(1));



contador=0;

for cc=Archivo1:Archivo2


    Netcdf=char(N(cc));  
    so=ncread(Netcdf,'so');
    so=so(Ix,Iy,:,:);
    zos=ncread(Netcdf,'zos');
    zos=zos(Ix,Iy,:,:);
    uo=ncread(Netcdf,'uo');
    uo=uo(Ix,Iy,:,:);
    vo=ncread(Netcdf,'vo');
    vo=vo(Ix,Iy,:,:);
    thetao=ncread(Netcdf,'thetao');
    thetao=thetao(Ix,Iy,:,:);
    
    for tiempo=1:length(uo(1,1,1,:))   %%Tiempo 12xanio
        
        contador=contador+1;
        
        for jj=1:31 %Numero de niveles del Modelo fisico depende hasta que nivel hay datos
            
            %%%%%%%%Salt%%%%%%%%%%%%
            s=squeeze(so(:,:,jj,tiempo));
            In=find((isnan(s))==0);
            SS(:,:,jj,contador)=griddata(double(lon1(In)),double(lat1(In)),double(s(In)),lon_rho,lat_rho,'v4');
            clear In
            
             %%%%%%%%Temp%%%%%%%%%%%%
            t=squeeze(thetao(:,:,jj,tiempo));
            In=find((isnan(t))==0);
            TT(:,:,jj,contador)=griddata(double(lon1(In)),double(lat1(In)),double(t(In)),lon_rho,lat_rho,'v4');
            clear In
            
                         %%%%%%%u%%%%%%%%%%%%
            u=squeeze(uo(:,:,jj,tiempo));
            In=find((isnan(u))==0);
            UU(:,:,jj,contador)=griddata(double(lon1(In)),double(lat1(In)),double(u(In)),lon_rho,lat_rho,'v4');
            clear In
            
                                     %%%%%%%u%%%%%%%%%%%%
            v=squeeze(vo(:,:,jj,tiempo));
            In=find((isnan(v))==0);
            VV(:,:,jj,contador)=griddata(double(lon1(In)),double(lat1(In)),double(v(In)),lon_rho,lat_rho,'v4');
            clear In
    
        end

                                                         %%%%%%%zeta%%%%%%%%%%%%

z=squeeze(zos(:,:,tiempo));
In=find((isnan(z))==0);
zeta(:,:,contador)=griddata(double(lon1(In)),double(lat1(In)),double(z(In)),lon_rho,lat_rho,'v4');
clear In
        
    end
end




clear j nn i 








for j=1:length(UU(1,1,1,:))
for nn=1:length(UU(1,1,:,1))

    
    aux=(UU(:,:,nn,j)+i.*VV(:,:,nn,j)).*exp(i.*-angle);
    Ucurr(:,:,nn,j)=real(aux);
    Vcurr(:,:,nn,j)=imag(aux);
end
end

File=strcat('FronterasMFRegNGC_',num2str(contii));

save (File,'SS','VV','UU','TT','zeta','hg','Ucurr','Vcurr','-v7.3')


clear 'SS' 'VV' 'UU' 'TT' 'zeta' 'Ucurr' 'Vcurr'

end

disp(strcat('Se termino interpolacion de los años: ',num2str(anioinicial),'-', num2str(aniofinal), ' se genero un archivo por año'))




% 
% clear Ad Adr angle Archivo1 Archivo2 auz bar cc contador Coordenadas_modelo j jj lat lat1 lon lon1 N Netcdf nn Nombrefile s S so t thetao tiempo u uo v vo z zos

% figure
% pcolor(lon_rho,lat_rho,no3(:,:,62,15))
% shading flat;grid;axis image;colormap('jet'); colorbar
% title('Interpolacion muestra, t=15')
% 
% 
% 
% figure
% pcolor(lon1,lat1,NO3(:,:,62,15))
% shading flat;grid;axis image;colormap('jet'); colorbar
% title('Original muestra, t=15')
% 
% I=find((isnan(no3))==1); 



