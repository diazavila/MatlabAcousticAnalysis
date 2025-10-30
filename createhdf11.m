% m-file createhdf6.m
% Create an EDF file and save the results of a .wav file

fields = fieldnames(Results);
FileName = replace(Mission_FILE, '.wav', '.h5');

% Create .h5 file if it does not exist
if ~isfile(FileName)
    h5create(FileName, strcat('/Data/fullband/',fields{25}), [1 5.*N]);
    h5create(FileName, strcat('/Data/broadband/',fields{16}), [1 5.*N]);
    h5create(FileName, strcat('/Data/third_octave/',fields{7}), [31 5.*N]);
    for i = 1:8
      h5create(FileName, strcat('/Data/fullband/',fields{25+i}), [1 N]);
      h5create(FileName, strcat('/Data/broadband/',fields{16+i}), [1 N]);
      h5create(FileName, strcat('/Data/third_octave/',fields{7+i}), [31 N]);
   end
end

% info = h5info(FileName)

% Write results to .h5 file
h5write(FileName, strcat('/Data/fullband/',fields{25}), eval(strcat('Results.',fields{25})));
h5write(FileName, strcat('/Data/broadband/',fields{16}), eval(strcat('Results.',fields{16})));
h5write(FileName, strcat('/Data/third_octave/',fields{7}), eval(strcat('Results.',fields{7})));
for i = 1:8
   h5write(FileName, strcat('/Data/fullband/',fields{25+i}), eval(strcat('Results.',fields{25+i})));
   h5write(FileName, strcat('/Data/broadband/',fields{16+i}), eval(strcat('Results.',fields{16+i})));
   h5write(FileName, strcat('/Data/third_octave/',fields{7+i}), eval(strcat('Results.',fields{7+i})));
end

% Write metadata to .h5 file
h5writeatt(FileName,'/','Raw_data_type', '.wav');
h5writeatt(FileName,'/','filename', Mission_FILE);
h5writeatt(FileName,'/','Fs', Fs);
h5writeatt(FileName,'/','Nbit', 24);
h5writeatt(FileName,'/','Temporal_resolution', '1 s');
h5writeatt(FileName,'/','Target_recording', "?");
h5writeatt(FileName,'/','Distance_from_the_target', '?');
h5writeatt(FileName,'/','duty_cycle', '100 percent on');
h5writeatt(FileName,'/','leq_averaging_time', '5');

% h5disp(FileName)
