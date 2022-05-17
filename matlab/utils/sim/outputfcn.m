function status = outputfcn(ts, xs, flag, logger, disp)

    
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
    
    if ~isempty(t)
        % Retrieve latest calculation from ODE solver
        status = updateLog(logger);
        if nargin > 4
            disp.update(xs(1:length(xs)/2,end));
            drawnow;
%             pause(0.01);
        end
    end
    
    
end
