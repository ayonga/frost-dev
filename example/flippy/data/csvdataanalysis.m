%% some files 
experiment1filename = '~/Downloads/experiment1.csv';
experiment2filename = '~/Downloads/experiment2.csv';
experiment3filename = '~/Downloads/experiment3.csv';
experiment4filename = '~/Downloads/experiment4.csv';
experiment5filename = '~/Downloads/experiment5.csv';

pickupandflipmatrixfilename1 = '/home/shishirny/repos/flippyws/src/grillbot/miso_simulation/config/FlippyBehaviorParameters.csv';
pickupandflipmatrixfilename2 = '/home/shishirny/repos/flippyws/src/grillbot/miso_simulation/config/FlippyBehaviorParametersBurger2.csv';
pickupandflipmatrixfilename3 = '/home/shishirny/repos/flippyws/src/grillbot/miso_simulation/config/FlippyBehaviorParametersBurger3.csv';

obstacleavoidancedatafilename = '~/Downloads/obstacleavoidance_5cmdeviation.csv';
deepobstacleavoidancedatafilename = '~/Downloads/deepobstacleavoidance_box.csv';

transA2Bfilename = '/home/shishirny/repos/flippyws/src/grillbot/miso_simulation/config/AtoBTrans.csv';
transB2Afilename = '/home/shishirny/repos/flippyws/src/grillbot/miso_simulation/config/BtoATrans.csv';
deepobstacletransA2Bfilename = '/home/shishirny/repos/flippyws/src/grillbot/miso_simulation/config/JointAngleDataB2A.csv';


%% here we exgract the data from the csv file
file_name = experiment1filename;
[time_data, angle_data] = getJointAngleData(file_name);
[njoints,npoints]=size(angle_data);

%% here we extract the desired trajectory 
file_name = pickupandflipmatrixfilename1;
alpha_param = dlmread(file_name,',');
nsegments = size(alpha_param,1)/(njoints+1);
t_finals = alpha_param(1:(njoints+1):(nsegments-1)*(njoints+1)+1,1);
time_sim_data=[];
sim_data = [];
    for i =1:numel(t_finals)
        t_samples = 0:0.01:t_finals(i);
        time_sim_data = [time_sim_data,t_samples+sum(t_finals(1:i-1))];
        sim_data = [sim_data,[poly_value_bezier(t_samples,alpha_param(2+(i-1)*(njoints+1),:));
                              poly_value_bezier(t_samples,alpha_param(3+(i-1)*(njoints+1),:));
                              poly_value_bezier(t_samples,alpha_param(4+(i-1)*(njoints+1),:));
                              poly_value_bezier(t_samples,alpha_param(5+(i-1)*(njoints+1),:));
                              poly_value_bezier(t_samples,alpha_param(6+(i-1)*(njoints+1),:));
                              poly_value_bezier(t_samples,alpha_param(7+(i-1)*(njoints+1),:))]];
    end
%% this is offset and nsamples for deep obstacle avoidance. it goes from A
% to B twice and then the box is thrown at it.
ofset = 14940;
nsamples = 1200;

%% this is offset and nsamples for small offset obstacle avoidance. it goes from A
% to B twice and then the box is pushed into the path a little bit.
ofset = 14954;
nsamples = 75;

%% this is offset and nsamples experiment1 data. Not sure what the experiment was
% must be flipping two burgers.
% first pickupandflip
percentageofset = 0.368;
percentagensamples = 0.3865;
scale = 1;
% % second pickupandflip
% percentageofset = 0.4191;
% percentagensamples = 0.4409;
% scale = 1.14;

%% this is offset and nsamples experiment5 data. Not sure what the experiment was
% percentageofset = 0.662;
% percentagensamples = 0.908;
% scale = 0.933;

%% plot maadi
angle_data_curtailed = angle_data(:,1+floor(percentageofset*npoints):floor(percentagensamples*npoints));
time_data_curtailed = time_data(1+floor(percentageofset*npoints):floor(percentagensamples*npoints))/scale;
offset_t = time_data_curtailed(1);
time_data_curtailed = time_data_curtailed - offset_t;
plot(time_data_curtailed,angle_data_curtailed,'.',time_sim_data,sim_data);
xlabel('Time (s)');
ylabel('Angles (rad)');

