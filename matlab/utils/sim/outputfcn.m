function status = outputfcn(ts, xs, flag, logger)

    
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
    end

end
