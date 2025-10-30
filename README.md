# MatlabAcousticAnalysis
Matlab software for analysis of underwater sound from .wav files.
The files in this reposity are intended for the anlysis of underwater
acoustic recording in .wav files. It will generate the following nine 
differente metrics: SPL, Leq, Lpea, L1, L5, L10, L50, L90 and L95 for 
the following signals: original, broadband (filtered from 20 Hz to 20 
KHz) and one-third-octave abdn signals from 20 Hz to 20 Khz (31 signals).
The results will be saved in .hd5 format, one .hdf5 filr per .wav file.
