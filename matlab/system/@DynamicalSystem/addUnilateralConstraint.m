function obj = addUnilateralConstraint(obj, name, constr, deps, auxdata)
    % Adds unilateral (inequality) constraints on the dynamical system
    % states and inputs
    %
    % Parameters:   
    %  name: the name of the constraint @type char
    %  constr: the symbolic representation of the unilateral constraints
    %  @type SymExpression
    %  deps: the dependent variables (could be states or inputs) @type
    %  cellstr
    %  auxdata: auxilary constant data @type cell

    if isfield(obj.UnilateralConstraints, name)
        error('The constraint (%s) has been already defined.\n',name);
    else
        assert(isvarname(name), 'The name must be a valid variable name.');
        
        if ~iscell(deps), deps = {deps}; end
        n_deps = length(deps);
        var_group = cellfun(@(x)obj.validateVarName(x), deps, 'UniformOutput', false);
        vars = cell(1,n_deps);
        for i=1:n_deps
            vars{i} = obj.(var_group{i}).(deps{i});
        end
        %% set the unilateral constraints
        if isa(constr, 'SymFunction')
            % validate the dependent variables
            assert(length(constr.Vars)==n_deps,...
                ['The constraint SymFunction (constr) must have the same',...
                'number of dependent variables as specified in the argument (deps).']);
            for i=1:n_deps
                assert(constr.Vars{i} == vars{i},...
                    'The %d-th dependent variable must be the same as the variable %s.',i,deps{i});
            end
            obj.UnilateralConstraints.(name).h = constr;
            obj.UnilateralConstraints.(name).deps = deps;
            if ~isempty(constr.Params)
                if nargin < 5
                    error('The constraint function requires auxilary constant parameters.');
                else
                    if ~iscell(auxdata), auxdata = {auxdata}; end
                    assert(length(constr.Params) == length(auxdata),...
                        'The number of required auxilaray data (%d) and the provided auxilary data (%d) does not match.\n',...
                        length(constr.Params),length(auxdata));
                    
                    obj.UnilateralConstraints.(name).auxdata = auxdata;
                end
                
            else
                obj.UnilateralConstraints.(name).auxdata = [];
            end
                    
            
        elseif isa(constr, 'SymExpression')
            % create a SymFunction object if the input is a SymExpression
            
            obj.UnilateralConstraints.(name).h = SymFunction(['u_' name '_' obj.Name], constr, vars);
            obj.UnilateralConstraints.(name).deps = deps;
            if nargin == 5
                error('If the constraint depends on auxilary constant parameters, please provide it as a SymFunction object directly.');
            end
            obj.UnilateralConstraints.(name).auxdata = [];
        else
            error('The constraint expression must be given as an object of SymExpression or SymFunction.');
        end
        
    end
end
