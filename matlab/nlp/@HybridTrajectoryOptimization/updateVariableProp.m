function obj = updateVariableProp(obj, name, phase, node, varargin)
    % This function updates the properties of the NLP variable objects
    % based on the input name-value pair arguments.
    %
    % Parameters:
    %  name: the row name of the constraints @type char
    %  phase: the phase index or the name @type double
    %  node: the identifier of the node list @type char
    %  varargin: variable nama-value pair input arguments, in detail:
    %   lb: lower limit @type colvec
    %   ub: upper limit @type colvec
    %   x0: a typical value of the variable @type colvec
    %  @type rowvec
    %
    %
    % @note The note identifier can be either the numbers of node indices
    % or the following string to specify particular nodes:
    % - 'first': the first node
    % - 'last': the last node
    % - 'all': all nodes
    % - 'cardinal': all cardinal (odd) nodes, only effective if
    % 'HermiteSimpson' scheme is used
    % - 'interior': all interior (even) nodes, only effective if
    % 'HermiteSimpson' scheme is used
    
    
    
    % get phase index
    phase_idx = getPhaseIndex(obj, phase);
    
    
    
    var_array = obj.Phase{phase_idx}.OptVarTable{name, :};
    
    if ischar(node)
        switch node
            case 'first'
                var_array{1} = updateProp(var_array{1}, varargin{:});
            case 'last'
                var_array{end} = updateProp(var_array{end}, varargin{:});
            case 'all'
                for i=1:obj.Phase{phase_idx}.NumNode
                    var_array{i} = updateProp(var_array{i}, varargin{:});
                end
            case 'cardinal'
                assert(strcmp(obj.Options.CollocationScheme, 'HermiteSimpson'),...
                    'Cardinal node identifier is only effective when ''HermiteSimpson'' scheme is used');
                for i=1:2:obj.Phase{phase_idx}.NumNode
                    var_array{i} = updateProp(var_array{i}, varargin{:});
                end
            case 'interior'
                assert(strcmp(obj.Options.CollocationScheme, 'HermiteSimpson'),...
                    'Interior node identifier is only effective when ''HermiteSimpson'' scheme is used');
                for i=2:2:obj.Phase{phase_idx}.NumNode-1
                    var_array{i} = updateProp(var_array{i}, varargin{:});
                end
            otherwise
                error('Unknown node identifier');
        end
    elseif isnumeric(node)
        for i=node
            var_array{i} = updateProp(var_array{i}, varargin{:});
        end
    else
        error('The node identifier must be a supported string or an array of node indices');
    end
            
    obj.Phase{phase_idx}.OptVarTable{name, :} = var_array;
end