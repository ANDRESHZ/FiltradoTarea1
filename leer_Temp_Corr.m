close all
clear all

%colocar aquí el nombre del archivo .mat
load TempCorrC1044

%las variables que nos interesan son 4: C02t, C20t, C13t y C31t, cada una
%de ellas está guardada como celdas de Matlab

N = size(C02t,1);

%%
%Loop para mostrar alguna de las cuatro variables
% generalmente la ultima celda son ceros, por lo que el loop llega a N-1

figure(1)
figure(2)
movegui(figure(1),'west');
movegui(figure(2),'east');


for i=2:N-1
    a=C02t{i};
    %a=C13t{i}+C13t{i-1};
    %a=C20t{i};
    %a=C31t{i};
    b=(C02t{i}-C02t{i-1});
    figure(1),imshow(a,[],'InitialMagnification', 1020)
    figure(2),imshow(b,[],'InitialMagnification', 1020)
end
