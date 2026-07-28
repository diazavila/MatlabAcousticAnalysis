% This script processes a set of RTSYS-generated directories based upn the
% CreateReport_OneFile script, producing results for:
% 1 - MSFD GES TSG 2013 Descriptor 11.1 and 11.2
% - Trend in 63Hz and 125 Hz third octave band, here taking 10 seconds as
% averaging period (PAR III of TSG noise 2.8.8 Recommendations "...should
% not exceed one minute)
% - Impulsive noise from 10Hz to 10 kHz
% This is a register
% 2- for wave Energy cOnverters: generally refer to EIA Directive
% 85/337/EEC Annexe IV and national regulations and in terms of
% implementation the SOWFIA EU Project final report recommendations D3.5
% (Oct 2013)
% - Peak Sound Presure levels
% - Show the theoreticacl zones of influence (Götz et al. 2009 and
% Richardson et al. 1995) -
% - Long time hours of spectral representations
% 3- Additional trends for third octaves up to 40 kHz
% Author :  Eric Delory 2017 - PLOCAN
% Modified by: José Antonio Diaz (5 Nov 2024) to:
% - Remove filter instability and adhere to IEC 61260-1 specs
% - Improve performance
% - Adapt to the Pure Wind project specs which include:
%   - Spoecific hydrophone sensitivity and gain
%   - Frequency band = 20 Hz to 20 KHz
%   - Generate L1, L5, L10, L50, L90, L95, Leq, Lmax and SPL
%   - SPL obervvation window = 1 s
%   - Leq averaging time = 5 s
%   - Outputa data format = HDF
% This script requires:
% - oct3dsgn1.m
% - oct3spec1.m
% - ChebyFilter1.m
% - createhdf11.m
clear; 
%_____________________________________________________________
% GLOBAL DATA ON SYSTEM - DO NOT CHANGE UNLESS SYSTEM IS DIFFERENT
% Hydrophone Sensitivity: RESON TC4032 differential input - 4 channels;
% (follows the following order - Channels [A, B, C, D]
Sh = [-183.41 -183.41 -183.41 -183.41]; % dB re 1V/uPa
% Important note:
% Channel D is the result of applying different gains to C input
% Gain correction from Channel A to D - these are linear values
Inv_Gain = [1/5.62341 1 1 1];
Inv_Gain_Correction = [1 1 1 1];
%_____________________________________________________________
%_____________________________________________________________
% ________________________________________
% PROCESSING - global values - must be edited
%
% Mission_DIR = 'C:\Users\jose.diaz\Documents\MATLAB\Data\Test';
% Mission_DIR = 'C:\Users\jose.diaz\OneDrive - Plataforma Oceánica de Canarias\Documentos\Matlab\PureWind\RTSys\Data\Test';
Mission_DIR = 'D:\PLOCAN_Bde_20240508-20240605_100ELISA_PUREWIND\Mod';
% Mission_DIR = 'D:\Data';
Channel = 1; % To select configuration gain correction (Channel 1 is input A)
WavChannel = 1; % to select the data in wav file (in RTSYS File ChannelCD__.wav D is WavChannel 2)
FilterOrderThirdBand = 3;
TimeWindowMSFD = 5; % seconds
AnalogValueFactor = 2.5*Inv_Gain(Channel)*Inv_Gain_Correction(Channel);
AnalogValueFactorSq = AnalogValueFactor.^2;
 Fc = [ 20, 25, 31.5, 40, 50, 63, 80, 100, 125, 160,  200, 250, 315, 400, 500, ...
    630, 800, 1000, 1250, 1600, 2000, 2500, 3150,  ...
    4000, 5000, 6300, 8000, 10000, ...
    12500, 16000, 20000];
    % , 25000, 32000, 40000, 50000, 64000, 80000, 100000];

%_____________________
% Start Processing
Directories = dir(Mission_DIR);
cd (Mission_DIR);
k=3; % Skipping . and .. dirs
for k =3:size(Directories,1)
    Directories(k).name
    cd(Directories(k).name)
    DirectoriesContentWav = dir('*.wav');
    for filecounter = 1:length(DirectoriesContentWav)
        Mission_FILE = DirectoriesContentWav(filecounter).name
        
        FILE_Info = audioinfo(Mission_FILE);
        FILE_Info_bin = dir(Mission_FILE);
        
        Fs = FILE_Info.SampleRate;
        Fc = Fc(Fc<Fs/2);
        SAMPLES = TimeWindowMSFD*Fs; % 1 sample includes all channels
        N = floor(FILE_Info.TotalSamples/TimeWindowMSFD/Fs);
        temp = ['Flie length = ',num2str(N*5),' s'];
        disp(temp)

        % Elaborate and display filters once - needs demoai_acoustic
        % toolbox
        if k==3 && filecounter ==1 %Only do this on first file
            FiltCoef = cell(size(Fc));
            gainoto = zeros(1,length(Fc));
            for f=1:length(Fc)
                [sos,g] = oct3dsgn1(Fc(f), Fs, FilterOrderThirdBand);
                FiltCoef{f} = sos;
                gainoto(f) = g;
                % oct3spec1(sos,g,Fs,Fc(f),'IEC',0);
                % axis('tight')
                % hold on
            end
            % axis([Fc(1)/10 Fc(end)*10 -40 5]);
            % disp ('Third-Band filters visualisation (hit key to continue)...')
            % pause
             
            % 20Hz-20kHz filter
            % The filter is based on a bandpass Chebyshev type I IIR filter.
            Hd = ChebyFilter2(Fs);
            gain = prod(Hd.ScaleValues);
            % disp ('Band-pass filter visualisation 20 Hz - 20 KHz (hit key to continue)...')
            % fvtool(Hd.sosMatrix);
            % pause
        end

        % Results for ThirdOctave-rms-L10-L90, Broadband-rms-L10-L90d and 10Hz-10kHz-rms-L10-L90
        
        Results = struct('FileName', Mission_FILE,'Channel', Channel ,'Frequencies', Fc, ...
            'SamplingFrequency', Fs, 'TimeWindow_sec', TimeWindowMSFD,'FilterOrderThirdBand', FilterOrderThirdBand ,...
            'ThirdBand_RMS', zeros(length(Fc),N*5), ...
            'ThirdBand_Leq', zeros(length(Fc),N), ...
            'ThirdBand_L1', zeros(length(Fc),N), ...
            'ThirdBand_L5', zeros(length(Fc),N), ...
            'ThirdBand_L10', zeros(length(Fc),N), ...
            'ThirdBand_L50', zeros(length(Fc),N), ...
            'ThirdBand_L90', zeros(length(Fc),N), ...
            'ThirdBand_L95', zeros(length(Fc),N), ...
            'ThirdBand_Peak', zeros(length(Fc),N), ...
            'Broadband20_20000_RMS',zeros(1,N*5), ...
            'Broadband20_20000_Leq',zeros(1,N), ...
            'Broadband20_20000_L1',zeros(1,N), ...
            'Broadband20_20000_L5',zeros(1,N), ...
            'Broadband20_20000_L10',zeros(1,N), ...
            'Broadband20_20000_L50',zeros(1,N), ...
            'Broadband20_20000_L90',zeros(1,N), ...
            'Broadband20_20000_L95',zeros(1,N), ...
            'Broadband20_20000_Peak',zeros(1,N), ...
            'Fullband_RMS',zeros(1,N*5), ...
            'Fullband_Leq',zeros(1,N), ...
            'Fullband_L1',zeros(1,N), ...
            'Fullband_L5',zeros(1,N), ...
            'Fullband_L10',zeros(1,N), ...
            'Fullband_L50',zeros(1,N), ...
            'Fullband_L90',zeros(1,N), ...
            'Fullband_L95',zeros(1,N), ...
            'Fullband_Peak',zeros(1,N));
        
        % Start Processing
        datetime
        xt = audioread(Mission_FILE,'double');
        START = 1;
        j=1;
        while START <= FILE_Info.TotalSamples - SAMPLES +1
            % disp(['File Processing Progress: ', int2str((j-1)*SAMPLES/FILE_Info.TotalSamples*100), '%']);
            x = xt(START:(START + SAMPLES-1),WavChannel);
            START = START + SAMPLES;
            % ThirdOctave
            i=1;
            for F=Fc
                sos = FiltCoef{i};
                y = gainoto(i).*sosfilt(sos,x);
                y = y.*y;
                ysort = sort(y);
                for k = 1:5
                   ini = Fs*(k-1)+1;
                   stp = Fs*k;
                   Results.ThirdBand_RMS(i,((j-1).*5+k))= 10*log10(mean(y(ini:stp))*AnalogValueFactorSq)-Sh(Channel);
                end
                Results.ThirdBand_Leq(i,j) = 10*log10(mean(y)*AnalogValueFactorSq)-Sh(Channel);
                Results.ThirdBand_L1(i,j)= 10*log10(ysort(floor(0.99*SAMPLES))*AnalogValueFactorSq)-Sh(Channel);
                Results.ThirdBand_L5(i,j)= 10*log10(ysort(floor(0.95*SAMPLES))*AnalogValueFactorSq)-Sh(Channel);
                Results.ThirdBand_L10(i,j)= 10*log10(ysort(floor(0.9*SAMPLES))*AnalogValueFactorSq)-Sh(Channel);
                Results.ThirdBand_L50(i,j)= 10*log10(ysort(floor(0.5*SAMPLES))*AnalogValueFactorSq)-Sh(Channel);
                Results.ThirdBand_L90(i,j)= 10*log10(ysort(floor(0.1*SAMPLES))*AnalogValueFactorSq)-Sh(Channel);
                Results.ThirdBand_L95(i,j)= 10*log10(ysort(floor(0.05*SAMPLES))*AnalogValueFactorSq)-Sh(Channel);
                Results.ThirdBand_Peak(i,j)= 10*log10(ysort(SAMPLES)*AnalogValueFactorSq)-Sh(Channel);
                i=i+1;
            end
            % Fullband
            y = x.*x;
            ysort = sort(y);
            for k = 1:5
               ini = Fs*(k-1)+1;
               stp = Fs*k;
               Results.Fullband_RMS(1,((j-1).*5+k))= 10*log10(mean(y(ini:stp))*AnalogValueFactorSq)-Sh(Channel);
            end
            Results.Fullband_Leq(1,j) = 10*log10(mean(y)*AnalogValueFactorSq)-Sh(Channel);
            Results.Fullband_L1(1,j)= 10*log10(ysort(floor(0.99*SAMPLES))*AnalogValueFactorSq)-Sh(Channel);
            Results.Fullband_L5(1,j)= 10*log10(ysort(floor(0.95*SAMPLES))*AnalogValueFactorSq)-Sh(Channel);
            Results.Fullband_L10(1,j)= 10*log10(ysort(floor(0.9*SAMPLES))*AnalogValueFactorSq)-Sh(Channel);
            Results.Fullband_L50(1,j)= 10*log10(ysort(floor(0.5*SAMPLES))*AnalogValueFactorSq)-Sh(Channel);
            Results.Fullband_L90(1,j)= 10*log10(ysort(floor(0.1*SAMPLES))*AnalogValueFactorSq)-Sh(Channel);
            Results.Fullband_L95(1,j)= 10*log10(ysort(floor(0.05*SAMPLES))*AnalogValueFactorSq)-Sh(Channel);
            Results.Fullband_Peak(1,j)= 10*log10(ysort(SAMPLES)*AnalogValueFactorSq)-Sh(Channel);
            % 20Hz-20kHz
            y = gain.*sosfilt(Hd.sosMatrix,x);
            y = y.*y;
            ysort = sort(y);
            for k = 1:5
               ini = Fs*(k-1)+1;
               stp = Fs*k;
               Results.Broadband20_20000_RMS(1,((j-1).*5+k))= 10*log10(mean(y(ini:stp))*AnalogValueFactorSq)-Sh(Channel);
            end
            Results.Broadband20_20000_Leq(1,j) = 10*log10(mean(y)*AnalogValueFactorSq)-Sh(Channel);
            Results.Broadband20_20000_L1(1,j)= 10*log10(ysort(floor(0.99*SAMPLES))*AnalogValueFactorSq)-Sh(Channel);
            Results.Broadband20_20000_L5(1,j)= 10*log10(ysort(floor(0.95*SAMPLES))*AnalogValueFactorSq)-Sh(Channel);
            Results.Broadband20_20000_L10(1,j)= 10*log10(ysort(floor(0.9*SAMPLES))*AnalogValueFactorSq)-Sh(Channel);
            Results.Broadband20_20000_L50(1,j)= 10*log10(ysort(floor(0.5*SAMPLES))*AnalogValueFactorSq)-Sh(Channel);
            Results.Broadband20_20000_L90(1,j)= 10*log10(ysort(floor(0.1*SAMPLES))*AnalogValueFactorSq)-Sh(Channel);
            Results.Broadband20_20000_L95(1,j)= 10*log10(ysort(floor(0.05*SAMPLES))*AnalogValueFactorSq)-Sh(Channel);
            Results.Broadband20_20000_Peak(1,j)= 10*log10(ysort(SAMPLES)*AnalogValueFactorSq)-Sh(Channel);
            j=j+1;
        end
        createhdf11;
    end
    cd ..
end