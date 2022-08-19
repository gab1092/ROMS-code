
##  Codigo en proceso.
##Depende del codigo de mapeo objetivo de barnes: Original, 10-Aug-09, S. Pierce, % Bug fix, 8-Sep-10, Carlos Carrillo 

cd (ruta_modeloglobal)

for anioo=anio1:anio2


addpath (ruta_modeloROMS)

angle=ncread('ROMS_ETOPO1_Regional.nc','angle');
lon_rho=ncread('ROMS_ETOPO1_Regional.nc','lon_rho');
lat_rho=ncread('ROMS_ETOPO1_Regional.nc','lat_rho');
lon_u=ncread('ROMS_ETOPO1_Regional.nc','lon_u');
lat_u=ncread('ROMS_ETOPO1_Regional.nc','lat_u');
lon_v=ncread('ROMS_ETOPO1_Regional.nc','lon_v');
lat_v=ncread('ROMS_ETOPO1_Regional.nc','lat_v');


mask_rho=ncread('ROMS_ETOPO1_Regional.nc','mask_rho');
I=find(mask_rho==0);mask_rho(I)=NaN;clear I
Cs_r=ncread('ROMS_ETOPO1_Regional.nc', 'Cs_r');


% load('BatimetriaMalla2_Ok.mat')
% h=-Hinterps;

h=ncread('ROMS_ETOPO1_Regional.nc','h');
I=find(h<0);
h(I)=0;

%  
% load FronterasCMEMS_parte1_Malla2 Ucurr Vcurr hg
  
    
    
ff=strcat('FronterasMFRegNGC_',num2str(anioo));

%load (ff,'UU','VV','TT','SS','hg')
 load (ff,'Ucurr','Vcurr','TT','SS','hg')


% 
% 
% for j=1:length(UU(1,1,1,:))
% for nn=1:length(UU(1,1,:,1))
% 
%     
%     aux=(UU(:,:,nn,j)+i.*VV(:,:,nn,j)).*exp(i.*-angle);
%     Ucurr(:,:,nn,j)=real(aux);
%     Vcurr(:,:,nn,j)=imag(aux);
% end
% end


N=31;
% load(hg)%%Niveles del modelo biogeoquimico en este caso
hg=hg(1:N); %%N=niveles hasta los que se considero el modelo 

hgo=ones(size(lon_rho(1,:))).*hg;
hgs=ones(size(lon_rho(:,1))).*hg';
hge=ones(size(lon_rho(end,:))).*hg;


%%%%%%%%%%%%%%%%%%%%%% coordenadas del modelo para cada frontera%%%%%%%%%%%%%%%%%

% lonoeste=lon_rho(1,:);
% latoeste=lat_rho(1,:);
% loneste=lon_rho(end,:);
% lateste=lat_rho(end,:);
lonsur=lon_rho(:,1);
latsur=lat_rho(:,1);

% lonoesteu=lon_u(1,:);
% latoesteu=lat_u(1,:);
% lonesteu=lon_u(end,:);
% latesteu=lat_u(end,:);
lonsuru=lon_u(:,1);
latsuru=lat_u(:,1);

% lonoestev=lon_v(1,:);
% latoestev=lat_v(1,:);
% lonestev=lon_v(end,:);
% latestev=lat_v(end,:);
lonsurv=lon_v(:,1);
latsurv=lat_v(:,1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

xxgs=lonsur.*ones(size(hg))';
% xxgo=lonoeste.*ones(size(hg));
% xxge=loneste.*ones(size(hg));


%%longituddes y niveles (profundidades) a los que se interpolara

hs=Cs_r.*h(:,1)';
% he=Cs_r.*h(end,:);
% ho=Cs_r.*h(1,:);

hu=griddata(lon_rho,lat_rho,h,lon_u,lat_u,'v4');
hv=griddata(lon_rho,lat_rho,h,lon_v,lat_v,'v4');


hsu=Cs_r.*hu(:,1)';
% heu=Cs_r.*hu(end,:);
% hou=Cs_r.*hu(1,:);


hsv=Cs_r.*hv(:,1)';
% hev=Cs_r.*hv(end,:);
% hov=Cs_r.*hv(1,:);

%%%
% xxe=ones(size(Cs_r))*loneste;
xxs=ones(size(Cs_r))*lonsur';
% xxo=ones(size(Cs_r))*lonoeste;

xxsu=ones(size(Cs_r))*lonsuru';
% xxou=ones(size(Cs_r))*lonoesteu;
% xxeu=ones(size(Cs_r))*lonesteu;


xxsv=ones(size(Cs_r))*lonsurv';
% xxov=ones(size(Cs_r))*lonoestev;
% xxev=ones(size(Cs_r))*lonestev;


for tiempo=1:length(Ucurr(1,1,1,:))
    
    U=squeeze(Ucurr(:,:,:,tiempo)); %seleccionando todos los datos para cada tiempo
    
%     %para el este
%     Ue=squeeze(U(end,:,:));   Ue=Ue';
%     IU=find(isnan(Ue)==0); %%arreglando
%     Ufe(:,:,tiempo)=barnes(xxge(IU),double(-hge(IU)),Ue(IU),xxeu',heu',0.02,100); %interpolando
%     
%     %%para el oeste
%     Uo=squeeze(U(1,:,:));   Uo=Uo'; IU=find(isnan(Uo)==0); %%arreglando
%     Ufop(:,:,tiempo)=barnes(xxgo(IU),double(-hgo(IU)),Uo(IU),xxou',hou',0.02,100); %interpolando
%     
%     
    %para el sur
    Us=squeeze(U(:,1,:)); IU=find(isnan(Us)==0); %%arreglando
    Ufs(:,:,tiempo)=barnes(xxgs(IU),double(-hgs(IU)),Us(IU),xxsu',hsu',0.4,40); %interpolando
    
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    V=squeeze(Vcurr(:,:,:,tiempo)); %seleccionando todos los datos para cada tiempo
%     
%     %para el este
%     Ve=squeeze(V(end,:,:)); Ve=Ve'; IV=find(isnan(Ve)==0); %%arreglando
%     
%     Vfe(:,:,tiempo)=barnes(xxge(IV),double(-hge(IV)),Ve(IV),xxev',hev',0.02,100); %interpolando
% %  
%%para el OESTE
%     Vo=squeeze(V(1,:,:)); Vo=Vo'; IV=find(isnan(Vo)==0); %%arreglando
%     
%     Vfo(:,:,tiempo)=barnes(xxgo(IV),double(-hgo(IV)),Vo(IV),xxov',hov',0.02,100); %interpolando
%     
%    %%% para el sur
     Vs=squeeze(V(:,1,:)); IV=find(isnan(Vs)==0); %%arreglando
     Vfs(:,:,tiempo)=barnes(xxgs(IV),double(-hgs(IV)),Vs(IV),xxsv',hsv',0.4,40); %interpolando
    
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     T=squeeze(TT(:,:,:,tiempo)); %seleccionando todos los datos para cada tiempo
% % %     
% % %     %para el este
% %     Te=squeeze(T(end,:,:)); Te=Te'; IT=find(isnan(Te)==0); %%arreglando
% %     
% %     Tfe(:,:,tiempo)=barnes(xxge(IT),double(-hge(IT)),Te(IT),xxe',he',0.02,100); %interpolando
% % %  
% % %%para el OESTE
% %    To=squeeze(T(1,:,:));To=To'; IT=find(isnan(To)==0); %%arreglando
% %     
% %    Tfo(:,:,tiempo)=barnes(xxgo(IT),double(-hgo(IT)),To(IT),xxo',ho',0.02,100); %interpolando
% %     
% %     %para el sur
     Ts=squeeze(T(:,1,:)); IT=find(isnan(Ts)==0); %%arreglando
     Tfs(:,:,tiempo)=barnes(xxgs(IT),double(-hgs(IT)),Ts(IT),xxs',hs',0.4,40); %interpolando
%      
%       
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       S=squeeze(SS(:,:,:,tiempo)); %seleccionando todos los datos para cada tiempo
% %     
% %     %para el este
% %     Se=squeeze(S(end,:,:)); Se=Se'; IS=find(isnan(Se)==0); %%arreglando
% %     
% %     Sfe(:,:,tiempo)=barnes(xxge(IS),double(-hge(IS)),Se(IS),xxe',he',0.02,100); %interpolando
% % %  
% % %%para el OESTE
% %    So=squeeze(S(1,:,:)); So=So'; IS=find(isnan(So)==0); %%arreglando
% %     
% %    Sfo(:,:,tiempo)=barnes(xxgo(IS),double(-hgo(IS)),So(IS),xxo',ho',0.02,100); %interpolando
% %     
% %    %%% para el sur
    Ss=squeeze(S(:,1,:)); IS=find(isnan(Ss)==0); %%arreglando
    Sfs(:,:,tiempo)=barnes(xxgs(IS),double(-hgs(IS)),Ss(IS),xxs',hs',0.4,40); %interpolando
% %     


end

fil=strcat('Fronteras',num2str(anioo));
save (fil, 'Ufs','Vfs','Tfs','Sfs','-v7.3')

end


