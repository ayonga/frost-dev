function obj = compileFunction(obj, model, varargin)
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
    
    
    
    
    
    % first compile all kinematics constraints defined for the
    % domain to create symbolic expressions
    cellfun(@(x)compileExpression(x, model, varargin{:}), obj.HolonomicConstraints);
    
    
    % get the symbol list for the kinematic functions
    symbols = cellfun(@(x) x.symbol,obj.HolonomicConstraints,'UniformOutput',false);
    
    % Stack all kinematic constraints into a vector
    eval_math([obj.hol_symbol,'=Join[Sequence@@',...
        cell2tensor(symbols,'ConvertString',false),'];']);
    
    for i=1:n_field
        field = field_names{i};
        
        switch field
            case 'hol_constr'
                % get the symbol list for the kinematic functions
                symbols = cellfun(@(x) x.symbol,obj.hol_constr,'UniformOutput',false);
                
                % Stack all kinematic constraints into a vector
                eval_math([obj.hol_symbol,'=Join[Sequence@@',...
                    cell2tensor(symbols,'ConvertString',false),'];']);
                
                % % check the size of the symbolic expression
                % hol_constr_size = math('math2matlab',['Dimensions[',obj.hol_symbol,']']);
                % assert(obj.n_hol_constr == hol_constr_size, ...
                %     'Domain:invalidsize',...
                %     ['The dimension of the holonomic constraint expression is %d.\',...
                %     'It should be %d.'],hol_constr_size,obj.n_hol_constr);
                
            case 'jac_hol_constr'
                % get the symbol list for the Jacobian of kinematic
                % functions
                jac_symbols = cellfun(@(x) x.jac_symbol,...
                    obj.hol_constr,'UniformOutput',false);
                
                % Stack all kinematic constraints into a vector
                eval_math([obj.hol_jac_symbol,'=Join[Sequence@@',...
                    cell2tensor(jac_symbols,'ConvertString',false),'];']);
            case 'jacdot_hol_constr'
                % get the symbol list for time derivative of the
                % Jacobian of kinematic functions
                jacdot_symbols = cellfun(@(x) x.jacdot_symbol,...
                    obj.hol_constr,'UniformOutput',false);
                
                % Stack all kinematic constraints into a vector
                eval_math([obj.hol_jacdot_symbol,'=Join[Sequence@@',...
                    cell2tensor(jacdot_symbols,'ConvertString',false),'];']);
            otherwise
                warning(['The ''field_names'' must be a string or cell strings',...
                    'that match one of these strings:\n',...
                    '%s,\t'],fields(obj.funcs));
                
        end
        
    end
    
    
end
