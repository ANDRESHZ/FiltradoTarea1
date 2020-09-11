clf;close all; clear all;                   
% load the demo data
load 'D:\BECA DOC\U Ponti Catoli Chile\SEMESTRE I\Proc Avanzado Imagenes\Tareas\Tarea 1\TempCorrC1044'
N=length(C02t)-1;
Real=zeros(79, 79, N);
Minimo=0;
Maximo=0;
for i=1:N
    Real(:,:,i)=C02t{i};
    auxMin=min(min(C02t{i}));
    auxMax=max(max(C02t{i}));
    if auxMin<Minimo
       Minimo=auxMin;
    end
    if auxMax>Maximo
        Maximo=auxMax;
    end
end
RealN=zeros(79, 79, N, 'uint8');
clean=zeros(79, 79, N, 'uint8');
RealN=((Real-Minimo)/(Maximo-Minimo)*255);

MetodoCl={'videosat','vbm3d','SIN Limpiar'}; %Metodos de pre procesamiento
onlineBMfg=[true,false];
addpath('salt_tool');  
%save('Iniciales.mat')
%% Filtros
%                   - sig: Sdesviacion standart del ruido
%                   - nSpatial: Spatial patch size as (Example: 64)
%%%%% no incluido   - stride: stride of overlapping patches (Example: 1)
%                   - strideTemporal: stride of overlapping frames (Example: 1)
%                   - nFrame: number of frames in each tensor patch(Example: 8)
%                   (Optional, set if you know what you are doing)
%                   - showStats: Set to 1, to output Status parameters
%                   - isTesting: Set to 1 for fast testing the code
auxNN=1;
sigK=0.08;
ExSALT=1;
OnliK=1;
metK=1;
OnliK=1;
nSpatialK=5;
nFramesK=2
striTemporalK=2;
% for sigK=2:2:12
%     %for metK=1:2:3
%        % for OnliK=1:1:2
%             for nSpatialK=8:4:16
%                 for nFramesK=2:2:4
%                     for striTemporalK=1:2:3
%                             if auxNN>=10                             
                                fprintf(">>Iteracion="+auxNN+"\n");
                                nombArchSv="Ejecucion-"+sigK+"-"+metK+"-"+OnliK+"-"+nSpatialK+"-"+nFramesK+"-"+striTemporalK+"-"+ExSALT+".mat"
                                load('Iniciales.mat')
                                param.sig       =   sigK; %% 20original o 2segundo
                                noisy           =   RealN;%double(clean) + param.sig * randn(size(clean));
                                % transfer to input data struct
                                data.noisy      =   double(RealN);
                                data.oracle     =   double(RealN);%double(clean);      % add if denoised analysis is required
                                % choose denoising method for precleaning
                                param.cleanMethod       =  MetodoCl{metK}; %% {'videosat','vbm3d','SIN Limpiar'}        % choose block matching style
                                param.onlineBMflag      =  true;% onlineBMfg(OnliK);
                               %% ------------- pre-cleaning -----------
                                % Input:    data
                                % Output:   ref: precleaned video, used for KNN block matching
                                % We provide 2 options as examples
                                % (1) using VIDOSAT gray-scale video denoising
                                if strcmp(param.cleanMethod, 'vidosat')
                                    VIDOSATparam.sig = param.sig;
                                    VIDOSATparam.nSpatial = nSpatialK; %64 original 16
                                    VIDOSATparam.stride = 1;         
                                    VIDOSATparam.nFrame = nFramesK;
                                    VIDOSATparam.strideTemporal = striTemporalK;
                                    addpath('./vidosat_tool');
                                    [ref, VIDOSATout] = VIDOSAT_videodenoising(data, VIDOSATparam);
                                %% (2) using VBM3D
                                elseif strcmp(param.cleanMethod, 'vbm3d')
                                    addpath('./BM3D');
                                    [psnrBM3D, ref] = VBM3D(data.noisy, param.sig, 0,0);
                                    %VBM3D_Bihan(data.noisy, param.sig, 0);
                                    ref        =   ref * 255;
                                else
                                % if no precleaning method is used, import noisy video for block matching   
                                    ref        =   data.noisy;
                                end
                                %% Blocking Matching 
                                % The block matching can be performed online, or offline
                                % There is a flag to control such option, param.onlineBMflag
                                if param.onlineBMflag
                                    % (1) online BM during SALT denoising
                                    param.onlineBMflag      =   true;
                                    data.ref                =   ref;
                                else
                                    % (2) offline BM before SALT denoising
                                    param.onlineBMflag  = false;
                                    [BMresult, BMsize, timeBM] = module_offlineBM(ref, param);
                                    data.BMresult = BMresult;
                                    data.BMsize = BMsize;
                                end

                                % ------------ Main Program : SALT based Video Denoising ---------------

                                [Xr, outputParam] = SALT_videodenoising(data, param);
                                fprintf('The PSNR of the SALT result = %.2f.\n', outputParam.PSNR);

                                % simulated noise standard deviation
                                %nombArchSv="Ejecucion-"+sigK+"-"+metK+"-"+OnliK+"-"+nSpatialK+"-"+nFramesK+"-"+striTemporalK+"-"+ExSALT+".mat"
                                %nombre del archivo
                                nombArchSv="Ejecucion-"+sigK+"-"+metK+"-"+OnliK+"-"+nSpatialK+"-"+nFramesK+"-"+striTemporalK+"-"+ExSALT+".mat";
                                fprintf("Iteracion="+auxNN+"\n---=>"+nombArchSv+"<=---\n");
                                save(nombArchSv)
                                
%                             end
%                          auxNN=auxNN+1;
%                     end
%                 end
%             end
%         %end
%     %end
% end