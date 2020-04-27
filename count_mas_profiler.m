close all; clear all; 
format long
addpath /home/nico/Documents/matlab_script


%% COMENTARIOS
%{
Los datos y el tiempo están en archivos separados. Datos en .dat, fechas
 en .date.

Hay dos estructuras, la primera es "z" que contiene los datos crudos con
la siguientes variables:
z = 

  struct with fields:

     time: [938×1 double]
    dat03: [938×1 double]
    dat05: [938×1 double]
    dat07: [938×1 double]
     dat1: [938×1 double]
     dat2: [938×1 double]
     dat3: [938×1 double]
     dat5: [938×1 double]
    dat10: [938×1 double]
La segunda estructura es "x" y está procesada desde "z", teniendo los
siguientes campos:
x = 

  struct with fields:

           time: [938×1 double]
            var: [938×7 double]
      diff_name: {'z03_05'  'z05_07'  'z07_1'  'z1_2'  'z2_3'  'z3_5'  'z5_10'}
           size: [0.300000000000000 0.500000000000000 0.700000000000000 1 2 3 5 10]
    diameter_um: [0.400000000000000 0.600000000000000 0.850000000000000 1.500000000000000 2.500000000000000 4 7.500000000000000]
           conc: [938×7 double]

Explicación del calculo de concentracion
%}

%% OBSERVACION IMPORTANTE
%{
Llamaremos bin a cada segmento que reporta el equipo, estos son:
 0.3um	 0.5um	 0.7um	 1.0um	 2.0um	 3.0um	 5.0um	 10.0um
El equipo reporta cantidad de partículas detectadas.
 
Según lo que se sabe de este equipo el valor reportado en el primer bin
(0.3) corresponde a:
 -La suma de cantidad de partículas totales desde 0.3um hasta 10 um
Lo reportado en el segundo bin 0.5 corresponde a:
 -La suma de cantidad de partículas entre 0.5um hasta 10 um.
y así con el resto de cantidades reportadas ...
%}

%% Detalle del cálculo
%{
-Se calculan la can
-Se calcula el volumen y la masa de particulas con los diametros
correspondiente al punto medio del bin, es decir, en el segmento 0.3 a 0.5,
se ocupa el 0.4 como DIÁMETRO. 
-Luego se multiplica la masa de cada partícula por la cantidad de
particulas reportada por el equipo.


RESPECTO AL VOLUMEN
El tema del volumne muestreado se asume que el equipo está midiendo con 1
litro por minuto (sin correcciones), y los valores entregados son las mediciones promedio
horarias de mediciones de 1 minuto donde pasa 1 litro.

Es decir el sistema de medición (nephelometro + datalogger) transmite en:
----
PROMEDIO HORARIO DE CANTIDAD DE PARTICULAS POR LITRO DE AIRE
----
obtenido desde mediciones x minuto. 

%}


%Calcular masa desde el profiler
rho = 1.65;%g/cm3 --> Wittmaack(2002)
pi = 3.141592654; 
%% preprocesar los archivos
% Esto se agregará como systemd
path_files = '/home/nico/Documents/cecs/olivares/profiler/data/profiler_23042020';
cd(path_files);
date_file = 'profiler_23042020.date';
data_file = 'profiler_23042020.data';

ini = datenum(2020,4,15);
fin = datenum(2020,4,22);
%sed -i -e 's/,/ /g' profiler_23042020.csv 
%awk '{print $1,$2}' profiler_23042020.csv > profiler_23042020.date
%awk '{print $3,$4,$5,$6,$7,$8,$9,$10,$11,$12}' profiler_23042020.csv > profiler_23042020.data
% awk '{print $4,$5,$6,$7,$8,$9,$10,$11}' profiler_23042020.csv >
% profiler_23042020.data % este es el que está operativo sin batería ni codigo de status 
%Eliminamos las comillas "" de las fechas
%sed -i -e 's/"//g' profiler_23042020.date
%se debería revisar el voltaje de batería y si hay errores en status del equipo

%% Cargo los datos
%dat = load('nefe.dat');%Promedio horario de (#partículas/1 Litro)
dat = load(data_file);
%fechas
%file = 'nefe.date';
file = date_file;
fid = fopen(file,'rt');
tem = textscan(fid,'%s','Delimiter',',','CollectOutput',1);
%z.time = [datenum(tem{1},'dd-mm-yyyy HH:MM')];
z.time = [datenum(tem{1},'yyyy-mm-dd HH:MM:SS')];
z.time = z.time - 4/24;
fclose(fid);

%asignamos
z.dat03 = dat(:,1); 
z.dat05 = dat(:,2); 
z.dat07 = dat(:,3);
z.dat1  = dat(:,4);
z.dat2  = dat(:,5);
z.dat3  = dat(:,6);
z.dat5  = dat(:,7);
z.dat10 = dat(:,8);

%% plot preliminar %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(1)
hold on
for i =1:8
plot(z.time,dat(:,i));
end
datetick
ylabel('Cuentas RAW')
xlabel('Tiempo')
grid on
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Segregamos por segmento de tamaño
x.time = z.time;
x.var(:,1) = z.dat03-z.dat05;
x.var(:,2) = z.dat05-z.dat07;
x.var(:,3) = z.dat07-z.dat1;
x.var(:,4) = z.dat1-z.dat2;
x.var(:,5) = z.dat2-z.dat3;
x.var(:,6) = z.dat3-z.dat5;
x.var(:,7) = z.dat5-z.dat10;
% los nomebres
x.diff_name = {'z03_05','z05_07','z07_1','z1_2','z2_3','z3_5','z5_10'};

%% plot de segmentos %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(2)
hold on
for j=1:7
plot(x.time,x.var(:,j))
end
datetick
grid on
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%tamaños de puntos de corte:
x.size = [0.3,0.5,0.7,1,2,3,5,10];
%diametros tomados desde la mitad de cada segmento, ej: segmento 0.3-0.5
%tiene un diámetro asignado de 0.4.
diameter = [0.4,0.6,0.85,1.5,2.5,4.0,7.5]; for ii =1:length(diameter); x.diameter_um(ii) = diameter(ii); end;

factor_conver = 10^(-4);%de [um] --> [cm] 
% calculo los volumenes V = 4/3 [pi (diameter/2)3] 
volumen = (4/3)*pi*(diameter*factor_conver/2).^3;% en cm3
mass_g =  volumen*rho;%[cm3]*[g/cm3] -> [g]
mass_ug = mass_g * 10^(6);%convertido a ug

%Delta_log10(d) = log10(d2)-log10(d1)% it gonna be useful later 
delta_log = [log10(0.5)-log10(0.3),log10(0.7)-log10(0.5),log10(1)-log10(0.7),log10(2)-log10(1),log10(3)-log10(2),log10(5)-log10(3),log10(10)-log10(5)];

%% *********** Calculamos concentración ug/m3. x.var[#particulas/L] x mass_ug[ug] x 1000 [convertir a m3] *********************
% Multiplicamos la masa[ug]*Cantidad_particulas*1000 y obtenemos en [ug/m3]
for jj=1:7
x.conc(:,jj) = mass_ug(jj)*x.var(:,jj)*1000;
end

for time=1:length(x.time) % El MP10 es la suma de todas las fracciones
x.mp10(time,1) = sum(x.conc(time,:));
x.mp25(time,1) = sum(x.conc(time,1:5));
end

figure(3)
plot(x.time,x.conc(:,1))
hold on
plot(x.time,x.mp10)
plot(x.time,x.mp25)
grid on
ylabel('MP10 [\mug m^{-3}]')
xlabel('Tiempo')
datetick
xlim([x.time(1) x.time(end)])
return
% figure(4);
% for jj = 1:length(x.var)
%     clf
% bar(x.var(jj,:));
% %pause(1)
% end








%% Preparo calculos para de distribución PAG.486 Aerosol Measurements(2011)
%El gráfico que se debe de hacer es lo siguiente
% En las partículas contadas entre 0.5um y 0.3um, el punto medio es d_i=0.4
% y calculamos el log_{10}(d_i) = log_{10}(0.4)=-0.3979. Esto se pone en el
% eje x.
%
% Para el eje "y" se calcula primero el /Delta
% log_{10}(d)=log(d_2)-log(d_1)=log(0.5)-log(0.3)=0.2.
% Luego calculamos la franción de particulas entre estos tamaños n_i y la
% dividimos por el total de partículas de la medición /sum(n_i), es decir
% tenemos I=frac{n_i}{sum(n_i)} y II=/Delta log(d). Finalmente en el eje "y"
% va I/II.



for time = 1:length(x.var)% genero la suma de todas las partículas contadas x cada tiempo
x.suma(time) = sum(x.var(time,:)); 
end
%% Fracción de cuentas
for time = 1:length(x.var)% 1 tiempo y los diferentes tamaños serían -> x.var(time,:)
    for size =1:7
        x.size_frac(time,size) = x.var(time,size)/x.suma(time);
    end
    %sum(x.size_frac(time,:))% esto tiene que sumar 1 simpre
    FRAC_MATRIX(:,time) = x.size_frac(time,:)';% se coloca en matriz para efectos de generar el gráfico
end



for i=1:length(x.size)-1
x.Dlog_d(i) = log10(x.size(i+1))-log10(x.size(i));
end


for time=1:length(x.var)
    for size=1:length(x.size)-1
        x.y_axe(time,size) = x.size_frac(time,size)/x.Dlog_d(size);
    end
    Size_distro(:,time) = x.y_axe(time,:)';
end

%% Filtrado de tiempo
t_indx = x.time >= ini & x.time <= fin;

%%


figure(5)
box on
axis on
pcolor(x.time,log10(x.diameter_um),Size_distro)
shading interp
xlim([x.time(1) x.time(end)])
%yticks(x.diameter_um)
a = get(gca,'YTickLabel');
set(gca,'YTickLabel',a,'FontName','Times','fontsize',8)
ylabel('log_{10}(D)')
datetick('x','dd/mm','keeplimits','keepticks')
oldcmap = colormap(jet);
%colormap(flipud(oldcmap));
h = colorbar%('northoutside')
%colorTitleHandle = get(h,'Title');
%titleString = '$\frac{n_i/\sum_{i=1}^7 n_i}{\Delta log_{10}(D)}$';
%set(colorTitleHandle ,'String',titleString,'interpreter','latex','FontSize',15);
ylabel(h, '$\frac{n_i/\sum_{i=1}^7 n_i}{\Delta log_{10}(D)}$','interpreter','latex','FontSize',15)
caxis([0 1])


figure(6)%histtograma de tamaños para un tiempo(t=200)
bar(x.size_frac(200,:))
ylim([0 1])
grid on

ff6 = figure(6)
box on
subplot(2,1,1)
axis on
plot(x.time,x.conc(:,1))
grid on
ylabel('MP10 [\mug m^{-3}]*')
xlabel('Tiempo')
xlim([x.time(1) x.time(end)])
datetick('x','dd/mm','keeplimits','keepticks')

subplot(2,1,2)
box on
axis on
pcolor(x.time,x.diameter_um,FRAC_MATRIX)
shading interp
xlim([x.time(1) x.time(end)])
yticks(x.diameter_um)
a = get(gca,'YTickLabel');
set(gca,'YTickLabel',a,'FontName','Times','fontsize',8)
ylabel('Díametro [\mum]')
datetick('x','dd/mm','keeplimits','keepticks')
oldcmap = colormap(jet);
%colormap(flipud(oldcmap));
h = colorbar('northoutside')
caxis([0 0.2])

%print(ff6,'-djpeg','Profiler_OA_particle_size_distribution_normal_zoom','-r2000')
%% Figura importante!


ff7 = figure(7)
title('Concentraciones malas ojo!')
box on
subplot(2,1,1)
axis on
plot(x.time,x.conc(:,1))
grid on
ylabel('MP10 [\mug m^{-3}]*')
%xlabel('Tiempo')
xlim([x.time(1) x.time(end)])
datetick('x','dd/mm','keeplimits','keepticks')

subplot(2,1,2)
pcolor(x.time,log10(x.diameter_um),Size_distro)
shading interp
xlim([x.time(1) x.time(end)])
%yticks(x.diameter_um)
a = get(gca,'YTickLabel');
set(gca,'YTickLabel',a,'FontName','Times','fontsize',8)
ylabel('log_{10}(D)')
datetick('x','dd/mm','keeplimits','keepticks')
oldcmap = colormap(jet);
%colormap(flipud(oldcmap));
h = colorbar('northoutside')
%colorTitleHandle = get(h,'Title');
%titleString = '$\frac{n_i/\sum_{i=1}^7 n_i}{\Delta log_{10}(D)}$';
%set(colorTitleHandle ,'String',titleString,'interpreter','latex','FontSize',15);
ylabel(h, '$\frac{n_i/\sum_{i=1}^7 n_i}{\Delta log_{10}(D)}$','interpreter','latex','FontSize',15)
caxis([0 1])

%print(ff7,'-djpeg','Profiler_OA_particle_size_distribution_log_normal_zoom__Def','-r2000')

%% sub gráfico del anterior 
% Guardamos
%format short 
%csvwrite('Nephelometer_mass_optic.csv',x.conc(:,1))
dlmwrite('Nephelometer_mass_optic.csv',x.conc(:,1),'delimiter','\t','precision',3)
dlmwrite('Nephelometer_mass_optic_V2.csv',x.mp10,'delimiter','\t','precision',3)
disp('EXPORTADOS LOS DATOS')

x.time = x.time(t_indx);
x.mp10 = x.mp10(t_indx);
x.conc = x.conc(t_indx,1);
Size_distro = Size_distro(:,t_indx);

%hacerla fácil, pero no muy elegante
x.conc = x.mp10
%

ff71 = figure(8)
box on
subplot(2,1,1)
axis on
plot(x.time,x.conc(:,1))
grid on
ylabel('MP10 [\mug m^{-3}]*')
%xlabel('Tiempo')
xlim([x.time(1) x.time(end)])
datetick('x','dd/mm','keeplimits','keepticks')

subplot(2,1,2)
pcolor(x.time,log10(x.diameter_um),Size_distro)
shading interp
xlim([x.time(1) x.time(end)])
%yticks(x.diameter_um)
a = get(gca,'YTickLabel');
set(gca,'YTickLabel',a,'FontName','Times','fontsize',8)
ylabel('log_{10}(D)')
datetick('x','dd/mm','keeplimits','keepticks')
oldcmap = colormap(jet);
%colormap(flipud(oldcmap));
h = colorbar('northoutside')
%colorTitleHandle = get(h,'Title');
%titleString = '$\frac{n_i/\sum_{i=1}^7 n_i}{\Delta log_{10}(D)}$';
%set(colorTitleHandle ,'String',titleString,'interpreter','latex','FontSize',15);
ylabel(h, '$\frac{n_i/\sum_{i=1}^7 n_i}{\Delta log_{10}(D)}$','interpreter','latex','FontSize',15)
caxis([0 1])

%print(ff71,'-djpeg','Profiler_OA_particle_size_distribution_log_normal_zoom__subtime_V2','-r2000')
return
%%
%% Quiero entender el ciclo diario de las concentraciones y ver a qué horas se dan las mayores concentraciones
clear z
z.time = x.time;
z.var = x.conc(:,1);
figure(8)
figures_cyclesND('daily_cycle_prctile',z,[],'Hora Local','MP10 [\mug m^{-3}]*')

return

%% Ahora quiero conocer el ciclo de viento 
%cd('/home/nico/Documents/cecs/olivares/profiler/wind')

dat = load('/home/nico/Documents/cecs/olivares/profiler/wind/OAlfaR_WD_WS.dat');
w.wdir = dat(:,1);
w.wspd = dat(:,2);

%fechas
%return
cd('/home/nico/Documents/cecs/olivares/profiler/wind')
file = 'OAlfaR.date';
fid = fopen(file,'rt');
tem = textscan(fid,'%s','Delimiter',',','CollectOutput',1);
w.time = [datenum(tem{1},'yyyy-mm-dd HH:MM:SS')];
w.time = w.time - 4/24;
fclose(fid);

figure(9)
plot(w.time,w.wspd)
datetick

figure(10)
plot(w.time,w.wdir)
datetick

% selecciono el tiempo

indx = w.time>=w.time(1) & w.time<= datenum(2016,9,1);

figure(11)
subplot(2,1,1)
plot(w.time(indx),w.wspd(indx))
datetick
subplot(2,1,2)
plot(w.time(indx),w.wdir(indx))
datetick

figure(12)
figures_cycles('daily_cycle_wind',w,[],0)

%figure(13)
%figures_cycles('season_cycle_wind',w,[],0)
