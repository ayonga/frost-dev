function ret = undersample(flow)
    dt = 0.016;
    t = flow.t;
    x = flow.states.x;
    
    t_final = t(end);
    n_t = round(t_final/dt);
    time = zeros(1,n_t+1);
    state = zeros(size(flow.states.x,1),n_t+1);
    for i = 1:n_t
        index = find(t>=(i-1)*dt,1);
        time(i) = t(index);
        state(:,i) = x(:,index);    
    end
    time(end) = t(end);
    state(:,end) = x(:,end);
    ret = [time;state];
end