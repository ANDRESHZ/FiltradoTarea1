clc; clf;close all; clear all;
%colocar aqui­ el nombre del archivo .mat
load TempCorrC1044
%las variables que nos interesan son 4: C02t, C20t, C13t y C31t, cada una
%de ellas esta guardada como celdas de Matlab
N = size(C31t,1);
%Loop para mostrar alguna de las cuatro variables
% generalmente la ultima celda son ceros, por lo que el loop llega a N-1
figure(1)
figure(2)
movegui(figure(1),'west');
movegui(figure(2),'east');
%Filtro="FMEdiana";
x=zeros(79*3, 79*2, N);
for i=1:N-1
    a=C20t{i};
    
    %b=(C31t{i+1}-C31t{i});
    %a=C13t{i}+C13t{i-1};
    %a=C20t{i};
    %a=C31t{i};
    %b=(C02t{i}-C02t{i-1});
%     b1=medfilt2(a,[2,2]);
     
    %b = imgaussfilt(a,[1 1],'FilterDomain','spatial');%Guassiano (frequency,,auto)
    %b=imdiffusefilt(a,'NumberOfIterations',1,'Connectivity','minimal'); %anisotropico N veces
%     [gradThresh,numIter] = imdiffuseest(a,'ConductionMethod','quadratic');%ajusta parametros
%     b = imdiffusefilt(a,'GradientThreshold', gradThresh,'NumberOfIterations',numIter);%Aplica anisotropico optimizado 
    %b=TVL1denoise(a, 0.3, 3); %Variacion total (imagen, lambda,iteraciones)
%     b = imnlmfilt(a,'ComparisonWindowSize',5,'SearchWindowSize',15,"DegreeOfSmoothing",0.0003);% non-localmeans
     c=imnlmfilt(a,'ComparisonWindowSize',3,'SearchWindowSize',15,"DegreeOfSmoothing",0.0004);
     d=imnlmfilt(a,'ComparisonWindowSize',5,'SearchWindowSize',15,"DegreeOfSmoothing",0.0004);
     e=imnlmfilt(a,'ComparisonWindowSize',7,'SearchWindowSize',15,"DegreeOfSmoothing",0.0004);
     f=imnlmfilt(a,'ComparisonWindowSize',11,'SearchWindowSize',15,"DegreeOfSmoothing",0.0004);
     
   nombre="D:\BECA DOC\U Ponti Catoli Chile\SEMESTRE I\Proc Avanzado Imagenes\Tareas\Tarea 1\Evidencias\"+Filtro+"-"+i+".bmp";
    figure(1),imshow([a,b,c;d,e,f],[],'InitialMagnification', 1020)
    %figure(1),imshow([a,b,c,d],[],'InitialMagnification', 1020)
    %imwrite(imresize([a b; c d],2,'box'),nombre);
    %figure(2),imshow(b,[],'InitialMagnification', 1020)
    x{i}=[a,b,c;d,e,f];
end

N=length(x)-1;
Real=zeros(79*3, 79*2, N);
Minimo=0;
Maximo=0;
for i=1:N
    Real(:,:,i)=x{i};
    auxMin=min(min(x{i}));
    auxMax=max(max(x{i}));
    if auxMin<Minimo
       Minimo=auxMin;
    end
    if auxMax>Maximo
        Maximo=auxMax;
    end
end
RealN=zeros(79, 79, N, 'uint8');
RealN=((Real-Minimo)/(Maximo-Minimo)*255);


%% Grabar videos de las secuencias de imagenes (gracias @Image Analyst)
%frames(:) = {zeros(1020, 1020, 1, 'uint8')}; %%obligamos a ser positivos
frames = cell(N-2,1);
MapaColor = cell(N-2,1);
MapaColor(:) = {zeros(256, 1)};% una capa de escala de gris
datoVideo = struct('cdata', frames, 'colormap', MapaColor);
set(gcf, 'renderer', 'zbuffer');%%opciones (OpenGL,zbuffer,painters)
for j = 1 : N-1
    a=C31t{j};
%     b=C02t{j+1}-C02t{j};
    b=medfilt2(a,[2,2]);
    c=medfilt2(a,[3,3]);
    d=medfilt2(a,[3,4]);
	cla reset;
	set(gcf, 'Units', 'Normalized', 'Outerposition', [0, 0, 1, 1]);%%aseguramos que quede completo
	imshow([a,b;c,d],[],'InitialMagnification', 1020)
	%title(sprintf('Frame #%d de %d', j, N-1), 'FontSize', 17);
	drawnow;
	FrameActu = getframe(gca);
	datoVideo(j) = FrameActu;
end
	startingFolder = pwd;%carpta incial del visor de archivos
	[nombBase, Carpeta] = uiputfile('*.avi', 'Video');
	if nombBase == 0 
		return;%%si pulso cancelar cierro
	end
	nombCompleto = fullfile(Carpeta, nombBase);
	[Carpeta, nombBase, ext] = fileparts(nombCompleto);
    ObjEscritura = VideoWriter(nombCompleto, 'Uncompressed AVI');
	open(ObjEscritura);
	nframes = length(datoVideo);
	for k = 1 : nframes 
	   writeVideo(ObjEscritura, datoVideo(k));
	end
	close(ObjEscritura);