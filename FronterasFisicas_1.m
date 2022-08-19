clear all
%%%Ese código es el primero de dos para generar datos de frontera para el modelo ROMS a partir de datos de modelos 
%%globales del copernicus marine service (https://marine.copernicus.eu/es). Los datos ya deben estar descargados.
%%  Este primer paso interpola de la malla del modelo global (lon, lat) a la malla del modelo ROMS (lon,lat). 
%%Después se usa el script FronterasFisicas_2.m
%%Este scrpit se corre y está probado en Matlab.
%%Elaborado por: Gabriela Reséndiz C. contacto: resendizg@cicese.edu.mx
%%Si detectas alguna falla o tienes alguna mejora no dudes en hacermelo saber :)

ruta_modeloglobal=input('Ruta de los archivos del modelo global: ');
ruta_modeloROMS=input('Ruta de la malla del ROMS: ');
X1=input('Longitud min:')
X2=input('Longitud max:')
Y1=input('Latitud min:')
Y2=input('Latitud max:')
cd (ruta_modeloglobal)

anioinicial=input('Año inicial: ');
aniofinal=input('Año final: ');


disp(strcat('Iniciando interpolacion de datos para modelo años: ',num2str(anioinicial),'-',num2str(aniofinal)))
% 
% time=ncread(Netcdf,'time');
% dn1950=datenum(1950,1,1)   % baseline point in Matlab datenum
% datestr(dn1950+time/24)

Archivo1=1;
Archivo2=12;  %%numero de meses, archivos por anio


addpath (ruta_modeloROMS)

angle=ncread(malla,'angle');
lon_rho=ncread(malla,'lon_rho');
lat_rho=ncread(malla,'lat_rho');
mask_rho=ncread(malla,'mask_rho');
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



Ix=find(lon>=X1 & lon<=Y2);
Iy=find(lat>=Y1 & lat<=Y2);

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





