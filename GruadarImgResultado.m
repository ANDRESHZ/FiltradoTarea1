clc;clf;clear all;
addpath('./IMGS')
ListaArch = ls('Ejecucion*.mat');
NArch=length(ListaArch(:,1))
set(gcf, 'renderer', 'zbuffer');
for i=1:1:NArch
     %set(gcf, 'Units', 'Normalized', 'Outerposition', [0, 0, 1, 1]);
     nombArch=strtrim(ListaArch(i,:));
     load(nombArch,'ref','Xr','noisy');
     nomNoisy="./IMGS/"+nombArch(1:length(nombArch) - 4)+".bmp";
     nomRest = "./IMGS/z"+nombArch(1:length(nombArch) - 4)+".bmp";
     %nomXr ="./IMGS/"+nombArch(1:length(nombArch) - 4)+"Xr.bmp"
     INoisy=uint8(noisy(:,:,15));
     IRef=uint8(ref(:,:,15));
     IXr=uint8(Xr(:,:,15));
     rest1=uint8((INoisy-IXr)*4);
     rest2=uint8((IXr-INoisy)*4);
     rest=zeros(79, 79, 3, 'uint8');
     rest(:,:,1)=rest1;
     rest(:,:,2)=rest2;
     imwrite(imresize(rest,6,'box'),nomRest);
   % imshow([INoisy IRef IXr],[],'InitialMagnification', 1020)
%     title(sprintf('Frame #%d de %d', i, NArch), 'FontSize', 17);
%     drawnow;
%     FrameActu = getframe(gca);
      imwrite(imresize([INoisy IRef; IXr rest1],6,'box'),nomNoisy);
%      imwrite(INoisy,nomNoisy);
%      imwrite(IRef,nomRef);
%      imwrite(IXr,nomXr);
end

