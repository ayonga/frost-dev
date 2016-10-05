function [y_a1, y_a2, Dy_a1, Dy_a2, DLfy_a2] = calcActualOutputs(obj, x, model)
    % calcActualOutputs- Calculate the actual outputs of the domain
    %   
    % 
    % Input: 
    %    * domain - domain
    %    * x  -  system states
    %
    % Output:
    %     y_a1, y_a2, Dy_a1, Dy_a2, DLfy_a2
    %
    % Copyright 2014-2015 Texas A&M University AMBER Lab
    % Author: Ayonga Hereid <ayonga@tamu.edu>

    
    
    
    %% relative degree one output
    if ~isempty(obj.ya1)
        % if relative degree one output is defined
        % call the specified MEX functions
        y_a1  = obj.ya1(x);
        
        if strcmpi(obj.outputs.type,'Time-Based')
            % if the desired outputs are time based, then assume time t as
            % a part of system state vector, and correspondingly add rows
            % associated with time 't' and 'dt' (which is 1)
            
            Dy_a1_temp = obj.Dya1(x);
            Dy_a1 = [0,Dy_a1_temp(model.qeIndices),...
                0,Dy_a1_temp(model.dqeIndices)];
            
        else
            % otherwise (state-based), then keep the original form
            Dy_a1 = obj.Dya1(x);
        end
    else
        y_a1  = [];
        Dy_a1 = [];
    end
    
    
    %% relative degree two outputs
    % call the specified MEX functions
    y_a2 = obj.ya2(x);
    
    nOutputsRD2 = numel(y_a2);
    assert(numel(obj.outputs.actual.degreeTwoOutput) == nOutputsRD2);
    
    if strcmpi(obj.outputs.type,'Time-Based')
            % if the desired outputs are time based, then assume time t as
            % a part of system state vector, and correspondingly add rows
            % associated with time 't' and 'dt' (which is 1)
            
            Dy_a2_temp = obj.Dya2(x);
            Dy_a2 = [zeros(nOutputsRD2,1),Dy_a2_temp(:,model.qeIndices),...
                zeros(nOutputsRD2,1),Dy_a2_temp(:,model.dqeIndices)];
            
            DLfy_a2_temp = obj.DLfya2(x);
            DLfy_a2 = [zeros(nOutputsRD2,1),DLfy_a2_temp(:,model.qeIndices),...
                zeros(nOutputsRD2,1),DLfy_a2_temp(:,model.dqeIndices)];
            
    else
        % otherwise (state-based), then keep the original form
        Dy_a2 = obj.Dya2(x);
        DLfy_a2 = obj.DLfya2(x);
    end
end