function obj = addHolonomicConstraint(obj, name, constr, jac, ddx)
    % Adds a holonomic constraint to the dynamical system
    %
    % A holonomic constraint is defined as a function of state variables
    % that equals to constants, i.e., 
    %   h(x) == hd
    %
    % Parameters:
    % name: the name of the constraint @type char
    % constr: the expression of the constraints @type SymExrpression
    % jac: the Jacobian of the constraints @type SymExpression
    % ddx: a symbolic representation of the ddx when the system is defined
    % as a first order system, but the holonomic constraint requires to be
    % enforced at the second derivatives @type SymExpression
    %
    % @note Any holonomic constraint introduces a set of constrained
    % wrenchs to the system (Lagrangian multiplier).
    
    
    
    
    
    if isfield(obj.HolonomicConstraints, name)
        error('The constraint (%s) has been already defined.\n',name);
    else
        assert(isvarname(name), 'The name must be a valid variable name.');
        
        % For each holonomic constraint, we define a parameter variable
        % (hd)
        n_constr = length(constr);
        hd = SymVariable(name,[n_constr,1]);
        obj.addParam(['p' name], hd);
        
        %% set the holonomic constraints
        % if isa(constr, 'SymFunction')
        %     assert(length(constr.Vars)==1 && constr.Vars{1} == obj.States.x,...
        %         'The SymFunction (constr) must be a function of only states (x).');
        %     obj.HolonomicConstraints.(name).h = SymFunction(['h_' name '_' obj.Name], ...
        %         tomatrix(constr)-hd, {obj.States.x,obj.Params.(name)});
        %
        % else
        if isa(constr, 'SymExpression')
            % create a SymFunction object if the input is a SymExpression
            % (assuming the constraitn is a function of states 'x');
            obj.HolonomicConstraints.(name).h = SymFunction(['h_' name '_' obj.Name], ...
                tomatrix(constr)-hd, {obj.States.x,obj.Params.(['p' name])});
            
        else
            error('The constraint expression must be given as an object of SymExpression or SymFunction.');
        end
        
        
        
        %% set the constraints Jacobian
        if nargin == 4 % if the Jacobian is given
            % check the size of the Jacobian matrix
            [nr,nc] = size(jac);
            
            assert(nr==n_constr && nc==obj.numState,...
                'The dimension of (Jh) is incorrect. Expected (%d x %d) matrix.', n_constr, obj.numState);
            
            % set the Jacobian matrix
            if isa(jac, 'SymFunction')
                assert(length(jac.Vars)==1 && jac.Vars{1} == obj.States.x,...
                    'The SymFunction (jac) must be a function of only states (x).');
                obj.HolonomicConstraints.(name).Jh = jac;
                
            elseif isa(jac, 'SymExpression')
                % create a SymFunction object if the input is a SymExpression
                % (assuming the constraitn is a function of states 'x');
                obj.HolonomicConstraints.(name).Jh = SymFunction(['Jh_' name '_' obj.Name], jac, {obj.States.x});
                
            else
                error('The constraint expression must be given as an object of SymExpression or SymFunction.');
            end
        else % otherwise, compute the Jacobian of the consraints directly
            jac = jacobian(constr, obj.States.x);
            obj.HolonomicConstraints.(name).Jh = SymFunction(['Jh_' name '_' obj.Name], jac, {obj.States.x});
        end
        dh = jac*obj.States.dx;
        obj.HolonomicConstraints.(name).dh = SymFunction(['dh_' name '_' obj.Name], dh, {obj.States.x,obj.States.dx});
        %% set the time derivative of the Jacobian
        % compute the time derivative of the Jacobian matrix if the system
        % is a second-order system (with ddx defined)
        if strcmp(obj.Type,'SecondOrder')
            ddx = obj.States.ddx;
        else
            if nargin < 5 % ddx is not provided for the first order  system
                ddx = [];
            end
        end
        
        if ~isempty(ddx)
            dJh = jacobian(jac*obj.States.dx, obj.States.x);
            obj.HolonomicConstraints.(name).dJh = SymFunction(['dJh_' name '_' obj.Name], dJh, {obj.States.x, obj.States.dx});
            ddh = jac*ddx + dJh*obj.States.dx;
            obj.HolonomicConstraints.(name).ddh = SymFunction(['ddh_' name '_' obj.Name], ddh, {obj.States.x, obj.States.dx,obj.States.ddx});
        else
            obj.HolonomicConstraints.(name).dJh = [];
            obj.HolonomicConstraints.(name).ddh = [];
        end
        %% Add constraint wrenchs
        
        lambda = SymVariable(name, [n_constr,1]);
        obj = addInput(obj, ['f' name], lambda, transpose(obj.HolonomicConstraints.(name).Jh));
    end
    
    
end