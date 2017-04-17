function ret = eval_math_fun(fun, args, opts, varargin)
    % Evaluate symbolic function
    %   eval_math_fun(fun,x1,...,xn) evaluates the symbolic function
    %   ''fun'' at the given arguments x1, ..., xn. 
    %
    % @author ayonga @date 2017-03-23
    %
    % Parameters:
    % fun: the name of the Mathematica function @type char
    % args: the input argument of the Mathematica function  @type cell
    % opts: the option argument of the Mathematica function @type cell
    % varargin: the option argument of the SymExpression object @type
    % varargin
    %
    % Example:
    % >> eval_math_fun('RandomReal',{10})
    % ans =
    %
    %   4.0980963150223175
    %
    %
    
    
%     assert(isvarname(fun),'The first argument must be a valid function name.');
    
    
    
    if nargin > 1
        if ~iscell(args), args = {args}; end;
        vars = cellfun(@(x)symbol(SymExpression(x)),args,'UniformOutput',false);
        svars = cell2tensor(vars,'ConvertString',false);
        if nargin > 2
            
            
            if ~isempty(opts)
                if iscell
                    opts = struct(opts{:});
                end
                
                opts_str = struct2assoc(opts,'ConvertString',false);
                
                fstr = [fun '[Sequence@@' svars ', Normal@' opts_str ']'];
            else
                fstr = [fun '[Sequence@@' svars ']'];
            end
        else
            fstr = [fun '[Sequence@@' svars ']'];
        end
    else
        fstr = [fun '[]'];
    end
    % return the updated object
    ret = SymExpression(fstr,varargin{:});
end