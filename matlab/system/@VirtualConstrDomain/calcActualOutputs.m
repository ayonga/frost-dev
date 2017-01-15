function y_act = calcActualOutputs(obj, qe, dqe)
    % Calculate the actual outputs of the domain
    %   
    % 
    % Parameters: 
    %  qe:  joint configuration @type colvec
    %  dqe: joint velocities @type colvec
    
    
    % initialize the actual output structure
    y_act = struct('ya1', [], ...
        'Dya1', [], ...
        'ya2', [], ...
        'Dya2', [], ...
        'DLfya2', []);
    
    
    %% relative degree one output
    if ~isempty(obj.ActVelocityOutput)
        % if relative degree one output is defined
        % call the specified MEX functions
        ya1_jac    = feval(obj.ActVelocityOutput.Funcs.Jac, qe);
        ya1_jacdot = feval(obj.ActVelocityOutput.Funcs.JacDot, qe, dqe);
        y_act.ya1  = ya1_jac*dqe;
        
        switch obj.PhaseVariable.Type
            case 'TimeBased'
                % if the desired outputs are time based, then assume time t as
                % a part of system state vector, and correspondingly add rows
                % associated with time 't' and 'dt' (which is 1)
                
                y_act.Dya1 = [0,ya1_jacdot,...
                    0,ya1_jac];
                
            case 'StateBased'
                % otherwise (state-based), then keep the original form
                y_act.Dya1 = [ya1_jacdot, ya1_jac];
        end
    end
    
    
    %% relative degree two outputs
    % call the specified MEX functions
    y_act.ya2  = feval(obj.ActPositionOutput.Funcs.Kin, qe);
    ya2_jac    = feval(obj.ActPositionOutput.Funcs.Jac, qe);
    ya2_jacdot = feval(obj.ActPositionOutput.Funcs.JacDot, qe, dqe);
    
    n_output = getDimension(obj.ActPositionOutput);
    
    assert( n_output == length(y_act.ya2),...
        ['The dimension of calculated position output does noe match the domain definition.\n',...
        'expected: %d\n'...
        'actual: %d.'], n_output, length(y_act.ya2));
    
    switch obj.PhaseVariable.Type
            case 'TimeBased'
                % if the desired outputs are time based, then assume time t as
                % a part of system state vector, and correspondingly add rows
                % associated with time 't' and 'dt' (which is 1)
                
                y_act.Dya2 = [zeros(n_output,1),ya2_jac,...
                    zeros(n_output,1),zeros(size(ya2_jac))];
                
                y_act.DLfya2 = [zeros(n_output,1),ya2_jacdot,...
                    zeros(n_output,1),ya2_jac];
                
        case 'StateBased'
            % otherwise (state-based), then keep the original form
            y_act.Dya2 = [ya2_jac, zeros(size(ya2_jac))];
            y_act.DLfya2 = [ya2_jacdot, ya2_jac];
    end
end