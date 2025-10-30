% m-file readedf1.m
% Read .h5 file

[file,location] = uigetfile('*.h5')
% FileName = 'channelA_2024-05-23_00-07-33.h5';

FileName = fullfile(location,file)
info = h5info(FileName)
h5disp(FileName)

DS = '/Data/broadband/Broadband20_20000_L1';
Broad.L1 = h5read(FileName,DS);
DS = '/Data/broadband/Broadband20_20000_L10';
Broad.L10 = h5read(FileName,DS);
DS = '/Data/broadband/Broadband20_20000_L5';
Broad.L5 = h5read(FileName,DS);
DS = '/Data/broadband/Broadband20_20000_L50';
Broad.L50 = h5read(FileName,DS);
DS = '/Data/broadband/Broadband20_20000_L90';
Broad.L90 = h5read(FileName,DS);
DS = '/Data/broadband/Broadband20_20000_L95';
Broad.L95 = h5read(FileName,DS);
DS = '/Data/broadband/Broadband20_20000_Leq';
Broad.Leq = h5read(FileName,DS);
DS = '/Data/broadband/Broadband20_20000_Peak';
Broad.Peak = h5read(FileName,DS);
DS = '/Data/broadband/Broadband20_20000_RMS';
Broad.RMS = h5read(FileName,DS);

DS = '/Data/fullband/Fullband_L1';
Full.L1 = h5read(FileName,DS);
DS = '/Data/fullband/Fullband_L10';
Full.L10 = h5read(FileName,DS);
DS = '/Data/fullband/Fullband_L5';
Full.L5 = h5read(FileName,DS);
DS = '/Data/fullband/Fullband_L50';
Full.L50 = h5read(FileName,DS);
DS = '/Data/fullband/Fullband_L90';
Full.L90 = h5read(FileName,DS);
DS = '/Data/fullband/Fullband_L95';
Full.L95 = h5read(FileName,DS);
DS = '/Data/fullband/Fullband_Leq';
Full.Leq = h5read(FileName,DS);
DS = '/Data/fullband/Fullband_Peak';
Full.Peak = h5read(FileName,DS);
DS = '/Data/fullband/Fullband_RMS';
Full.RMS = h5read(FileName,DS);

DS = '/Data/third_octave/ThirdBand_L1';
Third.L1 = h5read(FileName,DS);
DS = '/Data/third_octave/ThirdBand_L10';
Third.L10 = h5read(FileName,DS);
DS = '/Data/third_octave/ThirdBand_L5';
Third.L5 = h5read(FileName,DS);
DS = '/Data/third_octave/ThirdBand_L50';
Third.L50 = h5read(FileName,DS);
DS = '/Data/third_octave/ThirdBand_L90';
Third.L90 = h5read(FileName,DS);
DS = '/Data/third_octave/ThirdBand_L95';
Third.L95 = h5read(FileName,DS);
DS = '/Data/third_octave/ThirdBand_Leq';
Third.Leq = h5read(FileName,DS);
DS = '/Data/third_octave/ThirdBand_Peak';
Third.Peak = h5read(FileName,DS);
DS = '/Data/third_octave/ThirdBand_RMS';
Third.RMS = h5read(FileName,DS);
