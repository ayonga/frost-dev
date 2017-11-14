function writecsvfile(Behavior)
    r=[];
    for i=1:Behavior.nSubBehaviors
        r=[r;Behavior.SubBehavior(i).optimization_result];
    end

    filename = '/home/shishirny/repos/flippyws/src/grillbot/miso_simulation/config/FlippyBehaviorParameters.csv';
    dlmwrite(filename,r,'delimiter', ',','precision',16);
end