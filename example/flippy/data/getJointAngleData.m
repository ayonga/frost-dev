function [time_data,data] = getJointAngleData(filename)

startrow = 0;
startcolumn = 10;

data = dlmread(filename,',',startrow,startcolumn)';

fileID = fopen(filename);

textdata = textscan(fileID, '%f %f %f %s %s %s %s %s %s %s %d %d %d %d %d','delimiter', ',', 'EmptyValue', -Inf);
time_data = textdata{1}(1:2:end,1)';


cpu_freq = 6.e+08;

time_data  = (time_data - time_data(1))/cpu_freq;


end