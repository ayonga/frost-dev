function status = outputfcn(ts, xs, flag, ref)
t = [];
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
    calc = ref.h.calc;
    if isempty(calc)
        calc = struct();
    end
    % Append calculation to the global list
    ref.h.calcs{end + 1} = calc;
    % Clear calculation
    ref.h.calc = [];
end
status = 0; % if status is 1, solver stops
end
