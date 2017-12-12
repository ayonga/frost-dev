function writecsvfilebezier(t_final,a)

nparam = size(a,2);
r = [t_final,zeros(1,nparam-1);a];
csvwrite('/home/shishirny/repos/flippyws/src/grillbot/miso_simulation/config/FlippyBehaviorParameters.csv',r);

end