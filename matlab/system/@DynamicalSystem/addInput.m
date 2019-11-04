function obj = addInput(obj, category, name, var, gf, varargin)
    % Add input variables of the dynamical system
    %
    % Parameters:
    %  category: the category of the input @type char
    %  name: the name of the inputs @type char
    %  var: the symbolic variables or a list or number of input signals
    %  of the inputs @type SymVariable
    %  gf: the input map g(x) or g(x,u) @type SymFunction
    %  varargin: optional argument indicating whether the input is affine
    %  @type varargin
    % 
    % @note By default, we assume the input is affine.
    
    validatestring(category,{'Control','ConstraintWrench','External'});
    
    if strcmp(category,'Control')
        if ~isempty(fieldnames(obj.Inputs.Control))
            error('Multiple control variable detected. Please define only one group of control input signals.');
        end
    end
    
    if isfield(obj.Inputs.(category), name)
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
                
                assert(isempty(regexp(name, '\W', 'once')) || ~isempty(regexp(name, '\$', 'once')),...
                    'Invalid symbol string, can NOT contain special characters.');
                
                assert(isempty(regexp(name, '_', 'once')),...
                    'Invalid symbol string, can NOT contain ''_''.');
                
                assert(~isempty(regexp(name, '^[a-z]\w*', 'match')),...
                    'First letter must be lowercase character.');
            otherwise
                error('The third argument must be a positive integer, cellstr or a vector SymVaribale object.');
        end
        
        % parse the option, (assume it is affine by default)
        ip = inputParser;
        ip.addParameter('Affine',true,@(x) isequal(x,true) || isequal(x,false));
        ip.addParameter('LoadPath',[],@(x) ischar(x) || isempty(x));
        ip.parse(varargin{:});    
        opts = ip.Results;
        
        % Convert to SymExpression if the input argument is not
        if isempty(opts.LoadPath)
            if ~isa(gf,'SymExpression')
                s_gf = SymExpression(gf);
            else
                s_gf = gf;
            end
        else
            s_gf = SymExpression([]);
            s_gf = load(s_gf, opts.LoadPath, [name '_map_', obj.Name]);
        end
        % check the size of the gf
        [nr,nc] = size(s_gf);
        assert(nr==obj.numState,...
            'The input map must have the same number of rows as the number of states (%d).',obj.numState);
        
        
        
        if opts.Affine % The input is affine to the system
            assert(nc==length(var),...
                'The input map must have the same number of coloumns as the number of input variables (%d).',length(var));
            if isa(s_gf, 'SymFunction') % given as a SymFunction directly              
                sfun_gf = s_gf;
                assert((length(s_gf.Vars)==1 && s_gf.Vars{1} == obj.States.x) || isempty(s_gf.Vars),...
                    'The SymFunction (gf) must be a function of only states (x).');
            else % given as a SymExpression, then create a new SymFunction
                sfun_gf = SymFunction([name '_map_', obj.Name], s_gf, {obj.States.x});
            end
            if isempty(opts.LoadPath)
                sfun_gv = SymFunction([name '_vec_', obj.Name], s_gf*var, {obj.States.x,var});
            else
                sfun_gv = SymFunction([name '_vec_', obj.Name], [], {obj.States.x,var});
                sfun_gv = load(sfun_gv, opts.LoadPath);
            end
            obj.GmapName_.(category).(name) = sfun_gf.Name;
        else
            assert(nc==1,...
                'The input vector must be a column vector.');
            sfun_gf = [];
            obj.GmapName_.(category).(name) = '';
            if isa(s_gf, 'SymFunction') % given as a SymFunction directly                
                sfun_gv = s_gf;
                assert((length(s_gf.Vars)==2 && s_gf.Vars{1} == obj.States.x && s_gf.Vars{2}==var) || ...
                    (length(s_gf.Vars)==1 && s_gf.Vars{1} == var),...
                    'The SymFunction (gf) must be a function of states (x) and input (%d).',name);
            else % given as a SymExpression, then create a new SymFunction
                sfun_gv = SymFunction([name '_vec_', obj.Name], s_gf, {obj.States.x,var});
            end
        end
        
        
        % add a field with the name for Inputs, Gmap, Gvec, and inputs_
        obj.Inputs.(category).(name) = var;
        obj.Gmap.(category).(name) = sfun_gf;
        obj.Gvec.(category).(name) = sfun_gv;
        
        obj.GvecName_.(category).(name) = sfun_gv.Name;
        obj.inputs_.(category).(name) = nan(length(var),1);
    end
    
    
    
end
