function nlp = imposeNLPConstraint(obj, nlp)
    % impose holonomic objaints as NLP objaints in the trajectory
    % optimization problem 'nlp' of the dynamical system 
    %    
    %
    % Parameters:
    % nlp: the trajectory optimization NLP @type TrajectoryOptimization
    
    
    p_name = obj.ParamName;
    
    
    % h(x)-hd = 0 is enforced at the first node
    nlp = addNodeConstraint(nlp, obj.h_, {'x',p_name}, 'first',...
        0, 0, 'Nonlinear');
    
    if ~isempty(obj.ddh_) % if the second derivative of the object exists
        
       
        if strcmp(obj.Model.Type,'SecondOrder') % the second order system
            % enforce \dot{h}(x,dx) = J(x)dx = 0 at the first node
            nlp = addNodeConstraint(nlp, obj.dh_, {'x','dx'}, 'first',...
                0, 0, 'Nonlinear');
            % enforce \ddot{h}(x,dx,ddx) = 0 at all nodes
            nlp = addNodeConstraint(nlp, obj.ddh_, {'x','dx','ddx',p_name}, 'all',...
                0, 0, 'Nonlinear');
        elseif strcmp(obj.Model.Type, 'FirstOrder') % the first order system
            % enforce \dot{h}(x,dx) = J(x)dx = 0 at the first node
            nlp = addNodeConstraint(nlp, obj.dh_, {'x'}, 'first',...
                0, 0, 'Nonlinear');
            % enforce \ddot{h}(x,dx,ddx) = 0 at all nodes
            nlp = addNodeConstraint(nlp, obj.ddh_, {'x','dx',p_name},'all',...
                0, 0, 'Nonlinear');
        end
        
    else % if the second derivative of the object does not exist
        % enforce \dot{h}(x,dx) = J(x)dx at all nodes
        nlp = addNodeConstraint(nlp, obj.dh_, {'x','dx',p_name}, 'all',...
            0, 0, 'Nonlinear');
    end
        
    
end
