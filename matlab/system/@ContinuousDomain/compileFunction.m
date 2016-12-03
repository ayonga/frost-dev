function obj = compileFunction(obj, model, field_names, varargin)
    % Compiles the symbolic expression of functions related to the
    % class in Mathematica
    %
    % Parameters:
    %  model: a rigid body model of type RigidBodyModel
    %  field_names: specifies particular fields in the 'funcs' property
    %  that need to be compiled. If not specified explicitly, then
    %  compile all functions. @type cellstr
    %  varargin: optional arguments for kinematic compile function. 
    %
    % See also: Kinematics.compileExpression
    
    if nargin < 3
        %  If fields are not specified explicitly, set it to all
        %  fields of 'funcs'
        field_names = fields(obj.funcs);
    end
    
    if isempty(field_names) 
        % if the field name is empty, set it all fields of ''funcs''
        field_names = fields(obj.funcs);
    end
    
    if ischar(field_names)
        % if given as a string of single function, then converts to
        % a cell first.
        field_names = {field_names};
    end
    
    n_field = length(field_names);
    
    
    
    % first compile all kinematics constraints defined for the
    % domain to create symbolic expressions
    cellfun(@(x)compileExpression(x, model, varargin{:}), obj.hol_constr);
    
    for i=1:n_field
        field = field_names{i};
        
        switch field
            case 'hol_constr'
                % get the symbol list for the kinematic functions
                symbols = cellfun(@(x) x.symbol,obj.hol_constr,'UniformOutput',false);
                
                % Stack all kinematic constraints into a vector
                eval_math([obj.hol_symbol,'=Table[expr[[1]], {expr, ',...
                    cell2tensor(symbols,'ConvertString',false),'}];']);
                
                % % check the size of the symbolic expression
                % hol_constr_size = math('math2matlab',['Dimensions[',obj.hol_symbol,']']);
                % assert(obj.n_hol_constr == hol_constr_size, ...
                %     'ContinuousDomain:invalidsize',...
                %     ['The dimension of the holonomic constraint expression is %d.\',...
                %     'It should be %d.'],hol_constr_size,obj.n_hol_constr);
                
            case 'jac_hol_constr'
                % get the symbol list for the Jacobian of kinematic
                % functions
                jac_symbols = cellfun(@(x) x.jac_symbol,...
                    obj.hol_constr,'UniformOutput',false);
                
                % Stack all kinematic constraints into a vector
                eval_math([obj.hol_jac_symbol,'=Table[expr[[1,;;]], {expr, ',...
                    cell2tensor(jac_symbols,'ConvertString',false),'}];']);
            case 'jacdot_hol_constr'
                % get the symbol list for time derivative of the
                % Jacobian of kinematic functions
                jacdot_symbols = cellfun(@(x) x.jacdot_symbol,...
                    obj.hol_constr,'UniformOutput',false);
                
                % Stack all kinematic constraints into a vector
                eval_math([obj.hol_jacdot_symbol,'=Table[expr[[1,;;]], {expr, ',...
                    cell2tensor(jacdot_symbols,'ConvertString',false),'}];']);
            otherwise
                warning(['The ''field_names'' must be a string or cell strings',...
                    'that match one of these strings:\n',...
                    '%s,\t'],fields(obj.funcs));
                
        end
        
    end
    
    
end
