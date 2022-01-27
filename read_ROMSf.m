


function read_ROMSf(year,month,day,h,m,s,prefix,file_start,file_end,rutar,rutag)

%%Este codigo lee las salidas del ROMS (Regional Ocean Modeling System, https://www.myroms.org/)  y guarda como matrices (lon,lat,N,t)
%%las variables: fecha_actual,zeta,salt,temp,u y v, en un archivo anual.
%%year,month,day,h,m,s son para indicar el año, mes, dia, horas, minutos y segundos
%%usado como
%%referencia en las salidas del ROMS para calcular la fecha real de la
%%salida considerando. file_start y file_end=Numero del archivo inicial del roms,
%%formato de numero.
%%prefix=Prefijo del nombre del archivo antes del numero de archivo
%%Ej:'roms_his_' para el archivo 'roms_his_0001'
%%Escrito por Gabriela Resendiz Colorado, Posgrado en Ecologia Marina
%%CICESE
%%v1. 27/01/2022


num=0;

for cont=file_start:file_end
   
   num=num+1;
   
   
   if cont<10
       
       file=strcat(prefix,'000',num2str(cont),'.nc')
       
   end
   
   if cont>=10 & cont<100
       
       file=strcat(prefix,'00',num2str(cont),'.nc')
       
   end
   
   if cont>=100 & cont<1000
       file=strcat(prefix,'0',num2str(cont),'.nc')
   end
   
   if cont>=1000
       file=strcat(prefix,num2str(cont),'.nc')
   end
   
   %%fecha real
   file=strcat(rutar,file);
   ocean_time=ncread(file,'ocean_time'); %%segundos transcurridos
   ocean_time=ocean_time/86400; %%tiempo en dias transcurridos
   fecha_actual(:,:,num)=datetime(year,month,day,h,m,s)+days(ocean_time);
   
   ssh(:,:,num)=ncread(file,'zeta'); %%nivel del mar
   
   temp(:,:,:,num)=ncread(file,'temp'); %%SST

   salt(:,:,:,num)=ncread(file,'salt'); %%SSS
   
   u(:,:,:,num)=ncread(file,'u'); %%componente u


   v(:,:,:,num)=ncread(file,'u'); %%componente v
   
   clc
   
   
    yy=fecha_actual(:,:,1).Year;
   
   if fecha_actual(:,:,num)==datetime(yy,12,31,18,00,00)
     
     fileg=strcat(rutag,'/SalidaROMS',num2str(yy));
     save(fileg,'ssh','temp','salt','u','v','-v7.3')
   
     clear ssh temp salt u v
     num=0;
   
   end
   
   
end

print('Se terminaron de leer y guardar los datos')

end

