function Analyze(flow)

if nargin < 1
    t = logger.flow.t;
    states = logger.flow.states;
end
t  = flow.t;
datasize = size(t);
states = flow.states;

xdata =zeros(datasize);
ydata =zeros(datasize);
zdata =zeros(datasize);
oxdata = zeros(datasize);
oydata = zeros(datasize);
ozdata = zeros(datasize);
slipdata = zeros(datasize);
axdata = zeros(datasize);
aydata = zeros(datasize);
azdata = zeros(datasize);
normalvectordata = zeros(3,datasize(2));

for i = 1:datasize(2)
    x = states.x(:,i);
    dx = states.dx(:,i);
    ddx = states.ddx(:,i);
    zdata(1,i) = endeffz_sca_LR(x);
    ydata(1,i) = endeffy_sca_LR(x);
    xdata(1,i) = endeffx_sca_LR(x);
    oxdata(1,i)= o_endeffx_LR(x);
    oydata(1,i)= o_endeffy_LR(x);
    ozdata(1,i)= o_endeffz_LR(x);
    slipdata(1,i) = slipping_sca_LR(x,dx,ddx);
    axdata(1,i) = endeffax_sca_LR(x,dx,ddx);
    aydata(1,i) = endeffay_sca_LR(x,dx,ddx);
    azdata(1,i) = endeffaz_sca_LR(x,dx,ddx) -9.81;
    normalvectordata(:,i) = normal_vector_LR(x);
end

figure(301);
subplot(241);
plot3(xdata,ydata,zdata);grid on;
% quiver(axdata,aydata,azdata);
xlabel('x');
ylabel('y');
zlabel('z');axis equal
view(-30,30);
subplot(223);
plot(t,states.x);legend('j1','j2','j3','j4','j5','j6');
subplot(222);
plot(t,slipdata);
legend('slipping constraint');
subplot(224);
plot(t,oxdata,t,oydata,t,ozdata);legend('orientation x','orientation y','orientation z');
subplot(241);


figure(403);grid on;
for i =1:datasize(2)
    l=i;figure(403);
    plot3(xdata(1:l),ydata(1:l),zdata(1:l));
    pause(0.2);
end
figure(403);
for i =1:datasize(2)
    l=i;figure(403);
    quiver3(xdata(1:l),ydata(1:l),zdata(1:l),...
        normalvectordata(1,1:l),normalvectordata(2,1:l),normalvectordata(3,1:l));
    pause(0.2);
end
figure(403);
for i =1:datasize(2)
    l=i;figure(403);
    quiver3(xdata(1:l),ydata(1:l),zdata(1:l),...
        axdata(1:l),aydata(1:l),azdata(1:l));
    pause(0.2);
end