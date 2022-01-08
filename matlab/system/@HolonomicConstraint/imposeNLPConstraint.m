function nlp = imposeNLPConstraint(obj, nlp)
    % impose holonomic objaints as NLP objaints in the trajectory
    % optimization problem 'nlp' of the dynamical system 
    %    
    %
    % Parameters:
    % nlp: the trajectory optimization NLP @type TrajectoryOptimization
    
    p_name = obj.Params.Name;
    
    % h(x)-hd = 0 is enforced at the first node
    nlp = addNodeConstraint(nlp, 'first', obj.h_, {'x',p_name},...
        0, 0);
    
    if ~isempty(obj.ddh_) % if the second derivative of the object exists
        
        switch obj.SystemType
            case 'SecondOrder' % the second order system
                % enforce \dot{h}(x,dx) = J(x)dx = 0 at the first node
                nlp = addNodeConstraint(nlp, 'first', obj.dh_, {'x','dx'},...
                    0, 0);
                % enforce \ddot{h}(x,dx,ddx) = 0 at all nodes
                nlp = addNodeConstraint(nlp, 'all', obj.ddh_, {'x','dx','ddx'}, ...
                    0, 0);
            case 'FirstOrder'
                % enforce \dot{h}(x,dx) = J(x)dx = 0 at the first node
                nlp = addNodeConstraint(nlp, 'all', obj.dh_, {'x'}, ...
                    0, 0);
                % enforce \ddot{h}(x,dx,ddx) = 0 at all nodes
                nlp = addNodeConstraint(nlp, 'all', obj.ddh_, {'x','dx'},...
                    0, 0);
        end
        
    else % if the second derivative of the object does not exist
        % enforce \dot{h}(x,dx) = J(x)dx at all nodes
        nlp = addNodeConstraint(nlp, 'all', obj.dh_, {'x','dx'}, ...
            0, 0);
    end
    
end
