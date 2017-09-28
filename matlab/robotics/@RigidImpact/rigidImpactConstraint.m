function nlp = rigidImpactConstraint(obj, nlp, src, tar, bounds, varargin)
    % Impose system specific constraints as NLP constraints for the
    % trajectory optimization problem
    %
    % Parameters:
    % nlp: an trajectory optimization NLP object of the system
    % @type TrajectoryOptimization
    % src: the NLP of the source domain system
    % @type TrajectoryOptimization
    % tar: the NLP of the target domain system
    % @type TrajectoryOptimization
    % bounds: a struct data contains the boundary values @type struct
    % varargin: extra argument @type varargin
    
    
    
    addNodeConstraint(nlp, obj.xMap, {'x','xn'}, 'first', 0, 0, 'Linear');
    cstr_name = fieldnames(obj.ImpactConstraints);
    
    % the velocities determined by the impact constraints
    if isempty(cstr_name)
        % by default, identity map
        
        
        addNodeConstraint(nlp, obj.dxMap, {'dx','dxn'}, 'first', 0, 0, 'Linear');
    else
        %% impact constraints
        cstr = obj.ImpactConstraints;
        n_cstr = numel(cstr_name);
        input_name = cell(1,n_cstr);
        for i=1:n_cstr
            c_name = cstr_name{i};
            input_name{i} = cstr.(c_name).InputName;
        end
        
        
        
        addNodeConstraint(nlp, obj.dxMap, ['dx','xn', 'dxn', input_name], 'first', 0, 0, 'Linear');
        
    end
    
end
