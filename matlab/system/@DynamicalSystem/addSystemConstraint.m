function nlp = addSystemConstraint(obj, nlp)
    % Impose system specific constraints as NLP constraints for the
    % trajectory optimization problem
    %
    % Parameters:
    % nlp: an trajectory optimization NLP object 
    % @type TrajectoryOptimization

    
       
    
    % the holonomic constraints are enforced at the first node, the
    % derivatives of the holonomic constraints are enforced at all nodes
    h_constr_names = fieldnames(obj.HolonomicConstraints);
    n_h_constr = length(h_constr_names);
    if n_h_constr > 0
        
        
        for i=1:n_h_constr
            constr_name = h_constr_names{i};
            p_name = ['p' constr_name];
            constr = obj.HolonomicConstraints.(constr_name);
            
            % h(x)-hd = 0 is enforced at the first node
            nlp = addNodeConstraint(nlp, constr.h, {'x',p_name}, 'first',...
                0, 0, 'Nonlinear');
            
            if ~isempty(constr.ddh) % if the second derivative of the constraint exists
                % enforce \dot{h}(x,dx) = J(x)dx = 0 at the first node
                nlp = addNodeConstraint(nlp, constr.dh, {'x','dx'}, 'first',...
                    0, 0, 'Nonlinear');
                % enforce \ddot{h}(x,dx,ddx) = 0 at all nodes
                if strcmp(obj.Type,'SecondOrder') % the second order system
                    nlp = addNodeConstraint(nlp, constr.ddh, {'x','dx','ddx'}, 'all',...
                        0, 0, 'Nonlinear');
                elseif strcmp(obj.Type, 'FirstOrder') % the first order system
                    nlp = addNodeConstraint(nlp, constr.ddh, {'x','dx'},'all',...
                        0, 0, 'Nonlinear');
                end
                    
            else % if the second derivative of the constraint does not exist
                % enforce \dot{h}(x,dx) = J(x)dx at all nodes
                nlp = addNodeConstraint(nlp, constr.dh, {'x','dx'}, 'all',...
                    0, 0, 'Nonlinear');
            end
        end
    end
    
    
    % the unilateral constraints are enforced at all nodes
    u_constr_names = fieldnames(obj.UnilateralConstraints);
    n_u_constr = length(u_constr_names);
    if n_u_constr > 0
        
        
        for i=1:n_u_constr
            constr = obj.UnilateralConstraints.(u_constr_names{i});
            if ~isempty(constr.auxdata)
                nlp = addNodeConstraint(nlp, constr.h, constr.deps, 'all',...
                    0, inf, 'Nonlinear', constr.auxdata);
            else
                nlp = addNodeConstraint(nlp, constr.h, constr.deps, 'all',...
                    0, inf, 'Nonlinear');
            end
        end
    end
    
    % The virtual constraints 
    %     v_constr_names = fieldnames(obj.VirtualConstraints);
    %     n_v_constr = length(v_constr_names);
    %     if n_v_constr > 0
    %         for i=1:n_v_constr
    %             constr_name = v_constr_names{i};
    %             constr = obj.VirtualConstraints.(constr_name);
    %
    %             nlp = constr.imposeNLPConstraint(nlp);
    %         end
    %     end
    
end
