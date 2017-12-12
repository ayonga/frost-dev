figtype=1;
% plotthedata(time_data_curtailed,angle_data_curtailed(1,:),'Time(s)','Joint $1$',...
%                 'header','Angles','footer',{'Joint $1$'},'fignum',1);
%             
% plotthedata(time_data_curtailed,angle_data_curtailed(2,:),'Time(s)','Joint $2$',...
%                 'header','Angles','footer',{'Joint $2$'},'fignum',2);
%             
% plotthedata(time_data_curtailed,angle_data_curtailed(3,:),'Time(s)','Joint $3$',...
%                 'header','Angles','footer',{'Joint $3$'},'fignum',3);
%             
% plotthedata(time_data_curtailed,angle_data_curtailed(4,:),'Time(s)','Joint $4$',...
%                 'header','Angles','footer',{'Joint $4$'},'fignum',4);
% 
% plotthedata(time_data_curtailed,angle_data_curtailed(5,:),'Time(s)','Joint $5$',...
%                 'header','Angles','footer',{'Joint $5$'},'fignum',5);
% 
% plotthedata(time_data_curtailed,angle_data_curtailed(6,:),'Time(s)','Joint $6$',...
%                 'header','Angles','footer',{'Joint $6$'},'fignum',6);
% 
% plotthedata(time_sim_data,sim_data(1,:),'Time(s)','Joint Angles',...
%                 'header','Angles','footer',{'Joint $5$'},'fignum',1);



% hs25=figure(25);
% clf;
% set(hs25,'position',[100 100 1.0*540 1.0*400]);
% horizontallabelposition=[0.07 0.60];
% %
% hs = plot(time_data_curtailed,angle_data_curtailed(1,:),time_sim_data,sim_data(1,:));
% %                  axis([0 20 -0.1 100])
% set(gca,'FontSize',12);
% set(hs,'MarkerSize',6,'LineWidth',2);
% xlabel('Time (s)','Interpreter','LaTeX','Fontsize',30);
% ylabel('Joint $1$','Interpreter','LaTeX','Fontsize',30);
% legend({'$Actual$','$Desired$'},'Interpreter','LaTeX','FontSize',13);
% 
% apc = [0.17000000000000   0.165000000000   0.823000000000000   0.720000000000000];
% set(gca,'position',apc);


plotdatasimple(time_data_curtailed,angle_data_curtailed(1,:),time_sim_data,sim_data(1,:),'Time ($s$)','Joint $1$ $(rad)$',1,1,'northeast');

plotdatasimple(time_data_curtailed,angle_data_curtailed(2,:),time_sim_data,sim_data(2,:),'Time ($s$)','Joint $2$ $(rad)$',2,1,'southeast');

plotdatasimple(time_data_curtailed,angle_data_curtailed(3,:),time_sim_data,sim_data(3,:),'Time ($s$)','Joint $3$ $(rad)$',3,1,'southeast');

plotdatasimple(time_data_curtailed,angle_data_curtailed(4,:),time_sim_data,sim_data(4,:),'Time ($s$)','Joint $4$ $(rad)$',4,1,'northeast');

plotdatasimple(time_data_curtailed,angle_data_curtailed(5,:),time_sim_data,sim_data(5,:),'Time ($s$)','Joint $5$ $(rad)$',5,1,'southeast');

plotdatasimple(time_data_curtailed,angle_data_curtailed(6,:),time_sim_data,sim_data(6,:),'Time ($s$)','Joint $6$ $(rad)$',6,1,'southwest');


