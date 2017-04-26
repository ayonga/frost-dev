function obj = addInput(obj, name, var, gf, varargin)
    % Add input variables of the dynamical system
    %
    % Parameters:
    %  name: the name of the inputs @type char
    %  var: the symbolic variables or a list or number of input signals
    %  of the inputs @type SymVariable
    %  gf: the input map g(x) or g(x,u) @type SymFunction
    %  varargin: optional argument indicating whether the input is affine
    %  @type varargin
    % 
    % @note By default, we assume the input is affine.
    
    
    if isfield(obj.Inputs, name)
        error('The input (%s) has been already defined.\n',name);
    else
        switch class(var)
            case 'double'
                assert(isscalar(var) && rem(var,1)==0 && var > 0, ...
                    'The number of control inputs must be a positive integer.');
                % control input variables
                var = SymVariable(name,[var,1]);
            
            case 'cell'
                assert(isvector(var),...
                    'The list of the control input variables must be a vector cellstr array.');
                
                
                % control input variables
                var = SymVariable(name,[length(var),1],var);
            case 'SymVariable'                
                assert(isa(var,'SymVariable') && isvector(var), ...
                    'The third argument must be a vector SymVariable object.');
                % make a column vector
                if isrow(var)
                    var = SymVariable(transpose(tomatrix(var)));
                else
                    var = SymVariable(tomatrix(var));
                end
            otherwise
                error('The third argument must be a positive integer, cellstr or a vector SymVaribale object.');
        end
        
        % Convert to SymExpression if the input argument is not
        if ~isa(gf,'SymExpression') 
            s_gf = SymExpression(gf);
        else
            s_gf = gf;
        end
        
        % check the size of the gf
        [nr,nc] = size(s_gf);
        assert(nr==obj.numState,...
            'The input map must have the same number of rows as the number of states (%d).',obj.numState);
            
        % parse the option, (assume it is affine by default)
        ip = inputParser;
        ip.addParameter('Affine',true,@(x) isequal(x,true) || isequal(x,false));
        ip.parse(varargin{:});    
        opts = ip.Results;
        
        if opts.Affine % The input is affine to the system
            assert(nc==length(var),...
                'The input map must have the same number of coloumns as the number of input variables (%d).',length(var));
            if isa(s_gf, 'SymFunction') % given as a SymFunction directly
                assert(length(s_gf.Vars)==1 && s_gf.Vars{1} == obj.States.x,...
                    'The SymFunction (gf) must be a function of only states (x).');
                sfun_gf = s_gf;
            else % given as a SymExpression, then create a new SymFunction
                sfun_gf = SymFunction([name '_map_', obj.Name], s_gf, {obj.States.x});
            end
            
            sfun_gv = SymFunction([name '_vec_', obj.Name], s_gf*var, {obj.States.x,var});
            
        else
            assert(nc==1,...
                'The input vector must be a column vector.');
            sfun_gf = [];
            
            if isa(s_gf, 'SymFunction') % given as a SymFunction directly
                assert(length(s_gf.Vars)==2 && s_gf.Vars{1} == obj.States.x && s_gf.Vars{2}==var,...
                    'The SymFunction (gf) must be a function of states (x) and input (%d).',name);
                sfun_gv = s_gf;
            else % given as a SymExpression, then create a new SymFunction
                sfun_gv = SymFunction([name '_vec_', obj.Name], s_gf, {obj.States.x,var});
            end
        end
        
        
        obj.Inputs.(name) = var;
        obj.Gmap.(name) = sfun_gf;
        obj.Gvec.(name) = sfun_gv;
    end
    
    
    
end