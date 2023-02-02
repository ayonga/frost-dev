function status = outputfcn(ts, xs, flag, logger, disp, obj)
    % check 
    % time variable
    t = [];
    status = 0; % if status is 1, solver stops
    switch flag
        case 'init'
            t = ts(1);
        case []
            % The last point is what will be stored
            t = ts(end);    
        case 'done'
            % Do nothing
    end
    
    % output results from ode
    if ~isempty(t)
        % retrieve latest calculation from ODE solver
        status = updateLog(logger);
        
        % display animation during the simulation
        if nargin > 4
            disp.update(xs(1:length(xs)/2,end));
            drawnow;
%             pause(0.01);
        end
    end
    
    
end
