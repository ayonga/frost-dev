classdef SymExpression
    % A symbolic expression class that works (mostly) similar to ''sym'', but using
    % Mathematica kernal as the symbolic engine. 
    %
    % Copyright (c) 2016-2017, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    
    properties (Access=protected)
        s
    end
    
    
    methods
        
        function obj = SymExpression(x, n)
            % The class constructor function
            %
            % Parameters:
            % x: it could be one of the followings:
            %    - SymExpression: it will copy one SymExpression object to
            %    antother
            %    - numeric: create a numeric symbolic expression
            %    - char: create symbolic variable specified by the char 'x'
            % n: the dimenion of a 2-D symbolic matrices
            
            switch nargin
                case 0
                    % construct empty object
                    return;
                   
                case 1
                    switch class(x)
                        case 'SymVariable'
                            obj.s = x.s;
                        case 'SymExpression'                            
                            obj.s = x.s;
                        case 'double'
                            if isscalar(x)
                                obj.s = num2str(x);
                            else
                                obj.s = mat2math(x);
                            end
                        case 'char'
                            assert(isempty(regexp(x, '_', 'once')),...
                                'SymExpression:invaliadSymbol', ...
                                'Invalid symbol string, can NOT contain ''_''.');
                            assert(~check_var_exist(x),...
                                'SymExpression:invaliadSymbol',...
                                'The given symbol has already been already assigned a value.');
                            
                            obj.s = x;
                            
                        otherwise
                            error('SymExpression:invalidInputType',...
                                'Invalid input argument data type.');
                    end
                case 2
                    
                    assert(ischar(x), ...
                        'SymExpression:invaliadSymbol',...
                        ['The first argument must be a character vector specifying the base name for',...
                        'vector or matrix elements. It must be a valid variable name.']);                    
                    assert(isempty(regexp(x, '\W', 'once')),...
                        'SymExpression:invaliadSymbol', ...
                        'Invalid symbol string, can NOT contain special characters.');                    
                    assert(isempty(regexp(x, '_', 'once')),...
                        'SymExpression:invaliadSymbol', ...
                        'Invalid symbol string, can NOT contain ''_''.');
                    assert(~check_var_exist(x),...
                        'SymExpression:invaliadSymbol',...
                        'The given symbol has already been already assigned a value.');
                    
                    assert(isnumeric(n),...
                        'SymExpression:invaliadDimension',...
                        'The second argument must be numeric values that specify',...
                        'the dimensions of the generated symbolic vector or matrix');
                    
                    str = cell(n);
                    [nr, nc] = size(str);
                    for i = 1:nr
                        for j= 1:nc
                            str{i,j} = strcat('Subscript[', x, ', {',num2str(i),',',num2str(j),'}]');
                        end
                    end
                    obj.s = cell2tensor(str,'ConvertString',false);
                    
                   
                    
                    
            end
        end
        
        function display(obj, namestr) %#ok<INUSD,DISPLAY>
            % Display the symbolic expression
            
            eval_math(obj.s)
        end
        
        function y = length(obj)
            % The length of the symbolic vector
            %   LENGTH(X) returns the length of vector X.  It is equivalent
            %   to MAX(SIZE(X)) for non-empty arrays and 0 for empty ones.
            %
            % @see NUMEL, LENGTH
            
            if isempty(obj.s)
                y = 0;
                return;
            end
            
            dims = eval_math(['Dimensions[ToMatlabForm@',obj.s,']'],'math2matlab');
            y = max(dims);
        end
        
        function y = size(obj)
            % The size of the symbolic expression tensor
            %
            % @see NUMEL, LENGTH
            
            if isempty(obj.s)
                y = [0,0];
                return;
            end
            
            y = eval_math(['Dimensions[ToMatlabForm@',obj.s,']'],'math2matlab');
            
        end
        %---------------   Arithmetic  -----------------
        function B = uminus(A)
            % Symbolic negation.
            
            % Convert inputs to SymExpression
            A = SymExpression(A);
            
            % evaluate the operation in Mathematica and return the
            % expression string
            sstr = eval_math(['- ' A.s]);
            
            % create a new object with the evaluated string
            B = SymExpression(sstr);
        end

        function B = uplus(A)
            % Unary plus.
            
            % Convert inputs to SymExpression
            A = SymExpression(A);
            
            % evaluate the operation in Mathematica and return the
            % expression string
            sstr = eval_math(['+ ' A.s]);
            
            % create a new object with the evaluated string
            B = SymExpression(sstr);
        end

        function X = plus(A, B)
            % Symbolic plus operation.
            
            % Convert inputs to SymExpression
            A = SymExpression(A);
            B = SymExpression(B);
            % evaluate the operation in Mathematica and return the
            % expression string
            sstr = eval_math([A.s '+'  B.s]);
            % create a new object with the evaluated string
            X = SymExpression(sstr);
        end % plus

        function X = minus(A, B)
            % Symbolic minus operation.
            
            % Convert inputs to SymExpression
            A = SymExpression(A);
            B = SymExpression(B);
            % evaluate the operation in Mathematica and return the
            % expression string
            sstr = eval_math([A.s '+' B.s]);
            % create a new object with the evaluated string
            X = SymExpression(sstr);
        end % plus
        
        function X = times(A, B)
            % Symbolic array multiplication.
            %   TIMES(A,B) overloads symbolic A .* B.
            
            % Convert inputs to SymExpression
            A = SymExpression(A);
            B = SymExpression(B);
            % evaluate the operation in Mathematica and return the
            % expression string
            sstr = eval_math(['Times[' A.s ',' B.s ']']);
            % create a new object with the evaluated string
            X = SymExpression(sstr);
        end

        function X = mtimes(A, B)
            % Symbolic matrix multiplication.
            %   MTIMES(A,B) overloads symbolic A * B.
            
            if isscalar(B)
                X = times(A,B);
                return;
            end
            
            % Convert inputs to SymExpression
            A = SymExpression(A);
            B = SymExpression(B);
            % evaluate the operation in Mathematica and return the
            % expression string
            sstr = eval_math(['Dot[' A.s ',' B.s ']']);
            % create a new object with the evaluated string
            X = SymExpression(sstr);
        end

        function B = mpower(A,p)
            % Symbolic matrix power.
            %   MPOWER(A,p) overloads symbolic A^p.
            %
            %   Example;
            %      A = [x y; alpha 2]
            %      A^2 returns [x^2+alpha*y  x*y+2*y; alpha*x+2*alpha  alpha*y+4].
            
            % Convert inputs to SymExpression
            A = SymExpression(A);
            p = SymExpression(p);
            % evaluate the operation in Mathematica and return the
            % expression string
            sstr = eval_math(['MatrixPower[' A.s ',' p.s ']']);
            % create a new object with the evaluated string
            B = SymExpression(sstr);
        end

        function B = power(A,p)
            % Symbolic array power.
            %   POWER(A,p) overloads symbolic A.^p.
            %
            %   Examples:
            %      A = [x 10 y; alpha 2 5];
            %      A .^ 2 returns [x^2 100 y^2; alpha^2 4 25].
            %      A .^ x returns [x^x 10^x y^x; alpha^x 2^x 5^x].
            %      A .^ A returns [x^x 1.0000e+10 y^y; alpha^alpha 4 3125].
            %      A .^ [1 2 3; 4 5 6] returns [x 100 y^3; alpha^4 32 15625].
            %      A .^ magic(3) is an error.
            
            % Convert inputs to SymExpression
            A = SymExpression(A);
            p = SymExpression(p);
            % evaluate the operation in Mathematica and return the
            % expression string
            sstr = eval_math(['Power[' A.s ',' p.s ']']);
            % create a new object with the evaluated string
            B = SymExpression(sstr);
        end
        
        function X = rdivide(A, B)
            % Symbolic array right division.
            %   RDIVIDE(A,B) overloads symbolic A ./ B.
            %
            %   See also SYM/LDIVIDE, SYM/MRDIVIDE, SYM/MLDIVIDE, SYM/QUOREM.
            
            % Convert inputs to SymExpression
            A = SymExpression(A);
            B = SymExpression(B);
            % evaluate the operation in Mathematica and return the
            % expression string
            sstr = eval_math(['Divide[' A.s ',' B.s ']']);
            % create a new object with the evaluated string
            X = SymExpression(sstr);
        end
        
        function X = ldivide(A, B)
            % Symbolic array left division.
            %   LDIVIDE(A,B) overloads symbolic A .\ B.
            %
            %   See also SYM/RDIVIDE, SYM/MRDIVIDE, SYM/MLDIVIDE, SYM/QUOREM.
            
            % Convert inputs to SymExpression
            A = SymExpression(A);
            B = SymExpression(B);
            % evaluate the operation in Mathematica and return the
            % expression string
            sstr = eval_math(['Divide[' B.s ',' A.s ']']);
            % create a new object with the evaluated string
            X = SymExpression(sstr);
        end
        
        function X = mrdivide(A, B)
            %/  Slash or symbolic right matrix divide.
            %   A/B is the matrix division of B into A, which is roughly the
            %   same as A*INV(B) , except it is computed in a different way.
            %   More precisely, A/B = (B'\A')'. See SYM/MLDIVIDE for details.
            %   Warning messages are produced if X does not exist or is not unique.
            %   Rectangular matrices A are allowed, but the equations must be
            %   consistent; a least squares solution is not computed.
            %
            %   See also SYM/MLDIVIDE, SYM/RDIVIDE, SYM/LDIVIDE, SYM/QUOREM.
            
            % Convert inputs to SymExpression
            A = SymExpression(A);
            B = SymExpression(B);
            % evaluate the operation in Mathematica and return the
            % expression string
            sstr = eval_math(['Dot[' A.s ', Inverse[' B.s ']]']);
            % create a new object with the evaluated string
            X = SymExpression(sstr);
        end
        
        function X = mldivide(A, B)
            % Symbolic matrix left division.
            %   MLDIVIDE(A,B) overloads symbolic A \ B.
            %   X = A\B solves the symbolic linear equations A*X = B.
            %   Warning messages are produced if X does not exist or is not unique.
            %   Rectangular matrices A are allowed, but the equations must be
            %   consistent; a least squares solution is not computed.
            %
            %   See also SYM/MRDIVIDE, SYM/LDIVIDE, SYM/RDIVIDE, SYM/QUOREM.
            
            % Convert inputs to SymExpression
            A = SymExpression(A);
            B = SymExpression(B);
            % evaluate the operation in Mathematica and return the
            % expression string
            sstr = eval_math(['Dot[Inverse[' A.s '] ,'  B.s ']']);
            % create a new object with the evaluated string
            X = SymExpression(sstr);
        end
        
        function B = transpose(A)
            % Symbolic matrix transpose.
            %   TRANSPOSE(A) overloads symbolic A.' .
            %
            %   Example:
            %      [a b; 1-i c].' returns [a 1-i; b c].
            %
            %   See also SYM/CTRANSPOSE.
            
            
            % Convert inputs to SymExpression
            A = SymExpression(A);
            
            % evaluate the operation in Mathematica and return the
            % expression string
            sstr = eval_math(['Transpose[' A.s ']']);
            
            % create a new object with the evaluated string
            B = SymExpression(sstr);
        end
        
        function B = ctranspose(A)
            % Symbolic matrix complex conjugate transpose.
            %   CTRANSPOSE(A) overloads symbolic A' .
            %
            %   Example:
            %      [a b; 1-i c]' returns  [ conj(a),     1+i]
            %                             [ conj(b), conj(c)].
            %
            %   See also SYM/TRANSPOSE.
            
            
            % Convert inputs to SymExpression
            A = SymExpression(A);
            
            % evaluate the operation in Mathematica and return the
            % expression string
            sstr = eval_math(['ConjugateTranspose[' A.s ']']);
            
            % create a new object with the evaluated string
            B = SymExpression(sstr);
        end
        
        function B = inv(A)
            % Symbolic matrix inverse.
            %   INV(A) computes the symbolic inverse of A
            %   INV(VPA(A)) uses variable precision arithmetic.
            %
            %   Examples:
            %      Suppose B is
            %         [ 1/(2-t), 1/(3-t) ]
            %         [ 1/(3-t), 1/(4-t) ]
            %
            %      Then inv(B) is
            %         [     -(-3+t)^2*(-2+t), (-3+t)*(-2+t)*(-4+t) ]
            %         [ (-3+t)*(-2+t)*(-4+t),     -(-3+t)^2*(-4+t) ]
            %
            
            
            
            % Convert inputs to SymExpression
            A = SymExpression(A);
            
            % evaluate the operation in Mathematica and return the
            % expression string
            sstr = eval_math(['Inverse[' A.s ']']);
            
            % create a new object with the evaluated string
            B = SymExpression(sstr);
        end

        %---------------   Logical Operators    -----------------
        
        function y = eq(A, B)
            % Symbolic equality test.
            %   EQ(A,B) overloads symbolic A == B. If A and B are integers,
            %   rational numbers, floating point values or complex numbers
            %   then A == B compares the values and returns true or false.
            %   Otherwise A == B returns a sym object of the unevaluated equation
            %   which can be passed to other functions like solve. To force
            %   the equation to perform a comparison call LOGICAL or isAlways.
            %   LOGICAL will compare the two sides structurally. isAlways will
            %   compare the two sides mathematically.
            %
            %   See also SYM/LOGICAL, SYM/isAlways
            
            % Convert inputs to SymExpression
            A = SymExpression(A);
            B = SymExpression(B);
            % evaluate the operation in Mathematica and return the
            % expression string
            ret = eval_math(['SameQ[' A.s ','  B.s ']']);
            
            y = all(strcmp('True',ret));
        end

        function y = ne(A, B)
            %NE     Symbolic inequality test.
            %   NE(A,B) overloads symbolic A ~= B.  The result is the opposite of
            %   A == B.
            
            % Convert inputs to SymExpression
            A = SymExpression(A);
            B = SymExpression(B);
            % evaluate the operation in Mathematica and return the
            % expression string
            ret = eval_math(['UnsameQ[' A.s ','  B.s ']']);
            
            y = all(strcmp('True',ret));
        end

        

        
    end
    
    methods (Hidden=true)

        %---------------   Indexing  -----------------
        
        
        
        function [B] = subsref(L,Idx)
            %SUBSREF Subscripted reference for a sym array.
            %     B = SUBSREF(A,S) is called for the syntax A(I).  S is a structure array
            %     with the fields:
            %         type -- string containing '()' specifying the subscript type.
            %                 Only parenthesis subscripting is allowed.
            %         subs -- Cell array or string containing the actual subscripts.
            %
            %   See also SYM.
            
            if length(Idx)>1
                error(message('symbolic:sym:NestedIndex'));
            end
            
            % Convert inputs to SymExpression
            L = SymExpression(L);
            
            switch Idx.type
                case '.'
                    B = builtin('subsref', L, Idx);
                  
                case '()'
                        
                    
                    switch numel(Idx.subs)
                        case 0
                            sstr = eval_math(['ToVectorForm[' L.s ']']);
                        case 1
                            
                            sstr = eval_math(['ToVectorForm[' L.s ']']);
                            % special case shortcut for L(:)
                            if ischar(Idx.subs{1}) && strcmp(Idx.subs{1},':')
                                sstr = eval_math([sstr,'[[;;]]']);
                            elseif isnumeric(Idx.subs{1})
                                sstr = eval_math([sstr,'[[Flatten@',mat2math(Idx.subs{1}),']]']);
                            end
                            
                        case 2
                            ind = cell(1,2);
                            for i=1:2
                                if ischar(Idx.subs{i}) && strcmp(Idx.subs{i},':')
                                    ind{i} = ';;';
                                elseif isnumeric(Idx.subs{i})
                                    ind{i} = eval_math(['Flatten@',mat2math(Idx.subs{i})]);
                                end
                            end
                            
                            sstr = eval_math([L.s,'[[',ind{1},',',ind{2},']]']);
                        otherwise
                            % No support for indexing using '{}'
                            error('SymExpression:subsref', ...
                                'Not a supported subscripted reference.');                            
                    end
                    % create a new object with the evaluated string
                    B = SymExpression(sstr);
                case '{}'
                    % No support for indexing using '{}'
                    error('SymExpression:subsref', ...
                        'Not a supported subscripted reference.');
                otherwise
                    error('SymExpression:subsref', ...
                        'Not a supported subscripted reference.');
            end
            
            
            
        end
        
        function y = end(x,varargin)
            % Last index in an indexing expression for a sym array.
            %   END(A,K,N) is called for indexing expressions involving the sym
            %   array A when END is part of the K-th index out of N indices.  For example,
            %   the expression A(end-1,:) calls A's END method with END(A,1,2).
            %
            %   See also SYM.
            
            % Convert inputs to SymExpression
            x = SymExpression(x);
            
            sz = size(x);
            k = varargin{1};
            n = varargin{2};
            if n < length(sz) && k==n
                sz(n) = prod(sz(n:end));
            end
            if n > length(sz)
                sz = [sz ones(1, n-length(sz))];
            end
            y = sz(k);
        end
        
        %---------------   Conversions  -----------------

        function X = double(S)
            % Converts symbolic matrix to MATLAB double.
            %   DOUBLE(S) converts the symbolic matrix S to a matrix of double
            %   precision floating point numbers.  S must not contain any symbolic
            %   variables, except 'eps'.
            %
            %   See also SYM, VPA.
            
            % Convert inputs to SymExpression
            S = SymExpression(S);
            
            X = eval_math(['ToMatrixForm[' S.s ']'], 'math2matlab');
            
            
        end
    end
end