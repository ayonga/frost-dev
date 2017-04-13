function Y = subs(S,old,new) 
    % Symbolic substitution.  Also used to evaluate expressions numerically.
    %   SUBS(S,OLD,NEW) replaces OLD with NEW in the symbolic expression S.
    %   OLD is a symbolic variable, a string representing a variable name, or
    %   a symbolic expression. NEW is a symbolic or numeric variable
    %   or expression.  That is, SUBS(S,OLD,NEW) evaluates S at OLD = NEW.
    %
    %   SUBS(S,VALUES), where VALUES is a STRUCT, replaces the symbolic
    %   variables in S which are field names in VALUES by the corresponding
    %   entries of the struct.
    %
    %
    %   If OLD and NEW are vectors or cell arrays of the same size, each element
    %   of OLD is replaced by the corresponding element of NEW.  If S and OLD
    %   are scalars and NEW is a vector or cell array, the scalars are expanded
    %   to produce an array result.  If NEW is a cell array of numeric matrices,
    %   the substitutions are performed elementwise.
    %
    %   Examples:
    %     Single input:
    %       Suppose
    %          y = exp(-a*t)*C1
    %       After that, set a = 980 and C1 = 3 in the workspace.
    %       Then the statement
    %          subs(y)
    %       produces
    %          ans = 3*exp(-980*t)
    %
    %     Single Substitution:
    %       subs(a+b,a,4) returns 4+b.
    %       subs(a*b^2, a*b, 5) returns 5*b.
    %
    %     Multiple Substitutions:
    %       subs(cos(a)+sin(b),{a,b},[sym('alpha'),2]) or
    %       subs(cos(a)+sin(b),{a,b},{sym('alpha'),2}) returns
    %       cos(alpha)+sin(2)
    %
    %     Scalar Expansion Case:
    %       subs(exp(a*t),'a',-magic(2)) returns
    %
    %       [   exp(-t), exp(-3*t)]
    %       [ exp(-4*t), exp(-2*t)]
    %
    %     Multiple Scalar Expansion:
    %       subs(x*y,{x,y},{[0 1;-1 0],[1 -1;-2 1]}) returns
    %         0  -1
    %         2   0
    %
    %   See also SYM/SUBEXPR, SYM/VPA, SYM/DOUBLE.


    % Convert inputs to SymExpression
    S = SymExpression(S);
    
    narginchk(2,3);

    if nargin == 2
        assert(isstruct(old),'SymExpression:invalidInputArgs',...
            'The second argument must be a struct if there are two input arguments.');
        srule = SymExpression(old);
        
        sstr = ['ReplaceAll[' S.s ',' srule.s ']'];
        
        % create a new object with the evaluated string
        Y = SymExpression(sstr);
    elseif nargin == 3
        
        
        if iscell(old) && iscell(new)
            old_s = cellfun(@(x)SymExpression(x),old,'UniformOutput',false);
            new_s = cellfun(@(x)SymExpression(x),new,'UniformOutput',false);
            
            
            rarray = cellfun(@(x,y)[x.s '->' y.s], old_s, new_s ,'UniformOutput',false);
            srule = SymExpression(['<| ', ...
                implode(rarray,', '), ...
                ' |>']);
        elseif ischar(old)
            old_s = SymExpression(old);
            new_s = SymExpression(new);
            srule = SymExpression(['<| ', ...
                old_s.s, '->', new_s.s, ...
                ' |>']);
        elseif isa(old,'SymExpression')
            siz_o = size(old);
            siz_n = size(new);
            
            assert(prod(siz_o) == prod(siz_n),...
                'The sizes of the second and third argument must be the same.');
            old_s = flatten(SymExpression(old));
            new_s = flatten(SymExpression(new));
            rarray = arrayfun(@(x,y)['First@' x.s '->First@' y.s], old_s, new_s ,'UniformOutput',false);
            srule = SymExpression(['<| ', ...
                implode(rarray,', '), ...
                ' |>']);
        end
        
        
        
        sstr = ['ReplaceAll[' S.s ',' srule.s ']'];
        
        % create a new object with the evaluated string
        Y = SymExpression(sstr);
    end

