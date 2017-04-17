function obj = addSystemConstraint(obj)
    % Impose system constraints (holonomic and unilateral constraints) as NLP
    % constraints for the trajectory optimization problem
    %

    % basic information of NLP decision variables
    
    plant  = obj.Plant;
    
    % the unilateral constraints are enforced at all nodes
    u_constr_names = fieldnames(plant.UnilateralConstraints);
    n_u_constr = length(u_constr_names);
    if n_u_constr > 0
        
        
        for i=n_u_constr
            constr = plant.UnilateralConstraints.(u_constr_names{i});
            if ~isempty(constr.auxdata)
                obj = addNodeConstraint(obj, constr.h, constr.deps, 'all',...
                    0, inf, 'Nonlinear', constr.auxdata);
            else
                obj = addNodeConstraint(obj, constr.h, constr.deps, 'all',...
                    0, inf, 'Nonlinear');
            end
        end
    end
    
    
    % the holonomic constraints are enforced at the first node, ant the
    % derivatives of the holonomic constraints are enforced at all nodes
    h_constr_names = fieldnames(plant.HolonomicConstraints);
    n_h_constr = length(h_constr_names);
    if n_h_constr > 0
        
        
        for i=n_h_constr
            constr_name = h_constr_names{i};
            constr = plant.HolonomicConstraints.(constr_name);
            
            % h(x)-hd = 0 is enforced at the first node
            obj = addNodeConstraint(obj, constr.h, {'x',constr_name}, 'first',...
                0, 0, 'Nonlinear');
            
            if isfield(constr,'ddh') % if the second derivative of the constraint exists
                % enforce \dot{h}(x,dx) = J(x)dx = 0 at the first node
                obj = addNodeConstraint(obj, constr.dh, {'x','dx'}, 'first',...
                    0, 0, 'Nonlinear');
                % enforce \ddot{h}(x,dx,ddx) = 0 at all nodes
                if strcmp(plant.Type,'SecondOrder') % the second order system
                    obj = addNodeConstraint(obj, constr.ddh, {'x','dx','ddx'}, 'all',...
                        0, 0, 'Nonlinear');
                elseif strcmp(plant.Type, 'FirstOrder') % the first order system
                    obj = addNodeConstraint(obj, constr.ddh, {'x','dx'},'all',...
                        0, 0, 'Nonlinear');
                end
                    
            else % if the second derivative of the constraint does not exist
                % enforce \dot{h}(x,dx) = J(x)dx at all nodes
                obj = addNodeConstraint(obj, constr.dh, {'x','dx'}, 'all',...
                    0, 0, 'Nonlinear');
            end
        end
    end
    
end
