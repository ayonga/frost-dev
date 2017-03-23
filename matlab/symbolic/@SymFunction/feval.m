function varargout = feval(obj,varargin)
    % Evaluate symbolic function
    %   feval(F,x1,...,xn) evaluates the symbolic function F
    %   at the given arguments x1, ..., xn. If any of the
    %   arguments are matrices or n-dimensional arrays the
    %   function is vectorized over the matrix elements. The
    %   syntax F(x1...xn) is equivalent to feval(F,x1...xn).
    %
    %   If the body of F is nonscalar and any of the inputs
    %   is nonscalar then the output is a cell array the
    %   shape of the body of F and each element is the
    %   evaluation of the corresponding element of the body
    %   of F.
    
    
    if ~isa(obj,'SymFunction')
        [varargout{1:nargout}] = builtin('feval',obj,varargin{:});
        return;
    end
    
    nargoutchk(0,1);
    
    if ~isempty(obj.vars)
        if nargin == 1
            cvars = cellfun(@(x)x.s,obj.vars,'UniformOutput',false);
            svars = sprintf('%s, ',cvars{:});
            svars(end-1:end)=[];
            fstr = [obj.s '[' svars ']'];
        else 
            exprs = cellfun(@(x)SymExpression(x),varargin,'UniformOutput',false);
            cvars = cellfun(@(x)x.s,exprs,'UniformOutput',false);
            svars = sprintf('%s, ',cvars{:});
            svars(end-1:end)=[];
            fstr = [obj.s '[' svars ']'];
        end
    else
        fstr = [obj.s '[]'];
    end

    

    % return the updated object
    varargout{1} = SymExpression(fstr);
end


