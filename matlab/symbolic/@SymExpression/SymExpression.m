
classdef SymExpression < handle
    % An object that represents a symbolic expression in Mathematica
    %
    % Copyright (c) 2016-2017, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    
    properties (Access=protected)
        % The body (or formula) of the symbolic expression
        %
        % @type char
        f
    end
    
    properties (GetAccess=protected, SetAccess=protected)
        % The symbol that represents the symbolic expression
        %
        % @type char
        s
    end
    
    
    methods
        
        function obj = SymExpression(x, varargin)
            % The class constructor function
            %
            % Parameters:
            % x: it could be one of the followings:
            %    - SymExpression: it will copy one SymExpression object to
            %    antother
            %    - numeric: create a numeric symbolic expression
            %    - char: create symbolic expression specified by 'x'
            
            if nargin == 0 
                % construct empty object
                return;
            end
            
            
            opts = struct(varargin{:});
            if isfield(opts,'DelayedSet')
                if opts.DelayedSet == true
                    delayed_set = true;
                elseif opts.DelayedSet == false
                    delayed_set = false;
                else
                    error('A logical value is expected.');
                end
            else
                delayed_set = false;
            end
            
            
            
            
            
            if ~isa(x, 'SymExpression')
                if isempty(x)
                    obj.f = '{}';
                else
                    switch class(x)
                        case 'char'
                            obj.f = general2math(x,'ConvertString',false);
                        case 'string'
                            obj.f = general2math(x,'ConvertString',true);
                        case 'double'
                            
                            obj.f = general2math(x);
                        case 'cell'
                            obj.f = general2math(x,'ConvertString',false);
                        case 'struct'
                            obj.f = general2math(x,'ConvertString',true);
                        otherwise
                            error('SymExpression:invalidInputType',...
                                'Invalid input argument data type.');
                    end
                end
                obj.s = eval_math('Unique[symvar$]');
                if delayed_set
                    % delayed set the formula to the symbol
                    eval_math([obj.s ':=' obj.f ';']);
                else
                    % set the formula to the symbol
                    eval_math([obj.s '=' obj.f ';']);
                end
            else
                obj.f = formula(x);
                obj.s = x.s;
            end
            
            
            
            
            
            
        end
        
        function delete(~)
            % object destruction function
            
            %             eval_math([obj.s '=.;']);
        end
        
        function display(obj, namestr) %#ok<INUSD,DISPLAY>
            % Display the symbolic expression
            
            eval_math([obj.s])
        end
        
        function y = argnames(~)
            % Symbolic function input variables
            %   ARGNAMES(F) returns a sym array [X1, X2, ... ] of symbolic
            %   variables for F(X1, X2, ...).
            y = SymExpression();
        end

        function x = formula(A)
            %Symbolic expression formula body
            %   FORMULA(F) returns the definition of symbolic
            %   function F as a sym object expression.
            %
           
            x = A.f;
        end
        
        function x = symbol(A)
            %Symbolic expression symbol string
            %   SYMBOL(F) returns the symbolc string of symbolic
            %   expression F as a sym object expression.
            %
            x = A.s;
        end
        
        function y = privToCell(A)
            y = arrayfun(@(t){SymExpression(eval_math(['First@' t.s]))},A);
        end
        
        function y = length(A)
            % The length of the symbolic vector
            %   LENGTH(X) returns the length of vector X.  It is equivalent
            %   to MAX(SIZE(X)) for non-empty arrays and 0 for empty ones.
            %
            % @see NUMEL, SIZE
            
            
            
            y = max(size(A));
        end
        
        function varargout = size(A)
            % The size of the symbolic expression tensor
            %
            % @see NUMEL, LENGTH
            
            % Convert inputs to SymExpression
            %             A = SymExpression(A);
            
            if isempty(A.s)
                y = [0,0];
            else
                ret = eval_math(['Dimensions[',A.s,']']);
            
                y = cellfun(@(x)x, eval(ret));
                
                if isempty(y)
                    y = [1, 1];
                elseif isscalar(y) && y~=0
                    y = [1, y];
                elseif y == 0
                    y = [0, 0];
                end
            end
            
            
            
            
            if nargout == 0
                varargout{1} = y;
            elseif nargout == 1
                varargout{1} = y;
            else
                varargout = num2cell(ones(1,nargout));
                varargout([1:numel(y)]) = num2cell(y);
            end
        end
        
        function status = islist(A)
            % Check if the symbolic expression is a scalar (non-list)
            
            % Convert inputs to SymExpression
            A = SymExpression(A);
            
            % evaluate the operation in Mathematica and return the
            % expression string
            
            ret = eval_math(['ListQ[' A.s ']']);
            
            status = all(strcmp('True',ret));
        end
        function X = first(A)
            
            if ~islist(A)
                X = A;
                return;
            end
            % construct the operation string
            sstr = ['First[' A.s ']'];
            % create a new object with the evaluated string
            X = SymExpression(sstr);
        end
        %---------------   Arithmetic  -----------------
        function B = uminus(A)
            % Symbolic negation.
            
            % Convert inputs to SymExpression
            % A = SymExpression(A);
            
            % construct the operation string
            sstr = ['- ' A.s];
            
            % create a new object with the evaluated string
            B = SymExpression(sstr);
        end

        function B = uplus(A)
            % Unary plus.
            
            % Convert inputs to SymExpression
            % A = SymExpression(A);
            
            % construct the operation string
            sstr = ['+ ' A.s];
            
            % create a new object with the evaluated string
            B = SymExpression(sstr);
        end

        function X = plus(A, B)
            % Symbolic plus operation.
            
            % Convert inputs to SymExpression
            A = SymExpression(A);
            B = SymExpression(B);
            % construct the operation string
            sstr = [A.s '+'  B.s];
            % create a new object with the evaluated string
            X = SymExpression(sstr);
        end % plus

        function X = minus(A, B)
            % Symbolic minus operation.
            
            % Convert inputs to SymExpression
            A = SymExpression(A);
            B = SymExpression(B);
            % construct the operation string
            sstr = [A.s '-' B.s];
            % create a new object with the evaluated string
            X = SymExpression(sstr);
        end % plus
        
        function X = times(A, B)
            % Symbolic array multiplication.
            %   TIMES(A,B) overloads symbolic A .* B.
            
            % Convert inputs to SymExpression
            A = SymExpression(A);
            B = SymExpression(B);
            if isscalar(A) && islist(A) && islist(B)
                if isvectorform(A)
                    A = first(A);
                else
                    A = first(tovector(A));
                end
            end
            if isscalar(B) && islist(B) && islist(B)
                if isvectorform(B)
                    B = first(B);
                else
                    B = first(tovector(B));
                end
            end
            % construct the operation string
            sstr = ['Times[' A.s ',' B.s ']'];
            % create a new object with the evaluated string
            X = SymExpression(sstr);
        end
        
        
            
        function X = mtimes(A, B)
            % Symbolic matrix multiplication.
            %   MTIMES(A,B) overloads symbolic A * B.
            
            % Convert inputs to SymExpression
            A = SymExpression(A);
            B = SymExpression(B);
            
            if isscalar(B) || isscalar(A)
                X = times(A,B);
                return;
            end
            if isvectorform(A)
                A = flatten(A);
            end
            if isvectorform(B)
                B = flatten(B);
            end
            
            
            % construct the operation string
            sstr = ['Dot[' A.s ',' B.s ']'];
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
            % construct the operation string
            sstr = ['MatrixPower[' A.s ',' p.s ']'];
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
            % construct the operation string
            sstr = ['Power[' A.s ',' p.s ']'];
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

            if isscalar(A) && islist(A) && islist(B)
                A = first(A);
            end
            if isscalar(B) && islist(B) && islist(A)
                B = first(B);
            end
            % construct the operation string
            sstr = ['Divide[' A.s ',' B.s ']'];
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
            if isscalar(A) && islist(A) && islist(B)
                A = first(A);
            end
            if isscalar(B) && islist(B) && islist(A)
                B = first(B);
            end
            % construct the operation string
            sstr = ['Divide[' B.s ',' A.s ']'];
            % create a new object with the evaluated string
            X = SymExpression(sstr);
        end
        
        function X = mrdivide(A, B)
            %/  Slash or symbolic right matrix divide.
            %   A/B is the matrix division of B into A, which is roughly the
            %   same as A*INV(B) , except it is computed in a different way.
            %   More precisely, A / B = (B' \ A')'. See SYM/MLDIVIDE for details.
            %   Warning messages are produced if X does not exist or is not unique.
            %   Rectangular matrices A are allowed, but the equations must be
            %   consistent; a least squares solution is not computed.
            %
            %   See also SYM/MLDIVIDE, SYM/RDIVIDE, SYM/LDIVIDE, SYM/QUOREM.
            if isscalar(B) || isscalar(A)
                X = rdivide(A,B);
                return;
            end
            % Convert inputs to SymExpression
            A = SymExpression(A);
            B = SymExpression(B);
            % construct the operation string
            sstr = ['Dot[' A.s ', Inverse[' B.s ']]'];
            % create a new object with the evaluated string
            X = SymExpression(sstr);
        end
        
        function X = mldivide(A, B)
            % Symbolic matrix left division.
            %   MLDIVIDE(A,B) overloads symbolic A \ B.
            %   X = A \ B solves the symbolic linear equations A*X = B.
            %   Warning messages are produced if X does not exist or is not unique.
            %   Rectangular matrices A are allowed, but the equations must be
            %   consistent; a least squares solution is not computed.
            %
            %   See also SYM/MRDIVIDE, SYM/LDIVIDE, SYM/RDIVIDE, SYM/QUOREM.
            if isscalar(B) || isscalar(A)
                X = ldivide(A,B);
                return;
            end
            % Convert inputs to SymExpression
            A = SymExpression(A);
            B = SymExpression(B);
            % construct the operation string
            sstr = ['Dot[Inverse[' A.s '] ,'  B.s ']'];
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
            % A = SymExpression(A);
            
            % construct the operation string
            sstr = ['Transpose[' A.s ']'];
            
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
            % A = SymExpression(A);
            
            % construct the operation string
            %             sstr = ['ConjugateTranspose[' A.s ']'];
            sstr = ['Transpose[' A.s ']'];
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
            % A = SymExpression(A);
            
            % construct the operation string
            sstr = ['Inverse[' A.s ']'];
            
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
        
        function C = subsasgn(L,Idx,R)
            % Subscripted assignment for a sym array.
            %     C = SUBSASGN(L,Idx,R) is called for the syntax L(Idx)=R.  Idx is a structure
            %     array with the fields:
            %         type -- string containing '()' specifying the subscript type.
            %                 Only parenthesis subscripting is allowed.
            %         subs -- Cell array or string containing the actual subscripts.
            %
            %   See also SYM.
            
            %             error('Non implemented for SymExpression class.');
            if length(Idx)>1
                error('SymExpression objects do not allow nested indexing. Assign intermediate values to variables instead.');
            end
            if ~strcmp(Idx.type,'()')
                error('Invalid indexing assignment.');
            end
            if ~isempty(R)
                B = SymExpression(R);
            end
            switch numel(Idx.subs)
                case 0
                    error('An indexing expression on the left side of an assignment must have at least one subscript.');
                case 1
                    
                    sstr = symbol(L);
                    % special case shortcut for L(:)
                    if ischar(Idx.subs{1}) && strcmp(Idx.subs{1},':')
                        sstr = [sstr,'[[;;]]'];
                        if isempty(R)
                            eval_math([sstr '= {};']);
                        else
                            eval_math([sstr '= ' B.s ';']);
                        end
                    elseif isnumeric(Idx.subs{1})
                        ids = Idx.subs{1};
                        if isempty(R)
                            eval_math([sstr '=ToVectorForm[' sstr '];']);
                            eval_math([sstr '=Delete[' sstr ',' mat2math(ids(:)) '];']);
                            
                        else
                            for i=1:numel(ids)
                                [n,m] = ind2sub(size(L),ids(i));
                                sstr = [L.s,'[[',num2str(n),',', num2str(m),']]'];
                                eval_math([sstr '= ' general2math(R(i)) ';']);
                            end
                        end
                    else
                        error('The index is invalid.');
                    end
                    
                case 2
                    ind = cell(1,2);
                    if isempty(R)
                        error('A null assignment can have only one non-colon index.');
                    end
                    for i=1:2
                        if ischar(Idx.subs{i}) && strcmp(Idx.subs{i},':')
                            ind{i} = ';;';
                        elseif isnumeric(Idx.subs{i})
                            
                            ind{i} = eval_math(['Flatten@',mat2math(Idx.subs{i})]);
                        else
                            error('The index is invalid.');
                        end
                    end                    
                    sstr = [L.s,'[[',ind{1},',',ind{2},']]'];
                    eval_math([sstr '=' B.s]); 
                otherwise
                    error('SymExpression:subsref', ...
                        'Not a supported subscripted reference.');
            end
            % create a new object with the evaluated string
            C = L;
            
%             dosubs = false;
%             for k=1:length(inds)
%                 
%                 if isa(inds{k}, 'symfun') || isempty(inds{k}) || ~isAllVars(inds{k})
%                     dosubs = true;
%                 end
%             end
%             if dosubs
%                 if isa(L, 'symfun')
%                     error(message('symbolic:sym:subscript:InvalidIndexOrFunction'));
%                 end
%                 C = privsubsasgn(L,R,inds{:});
%             else
%                 C = symfun(sym(R),[inds{:}]);
%             end
        end
        
        function [B] = subsref(L,Idx)
            % Subscripted reference for a sym array.
            %     B = SUBSREF(A,S) is called for the syntax A(I).  S is a structure array
            %     with the fields:
            %         type -- string containing '()' specifying the subscript type.
            %                 Only parenthesis subscripting is allowed.
            %         subs -- Cell array or string containing the actual subscripts.
            %
            
            
            %             if length(Idx)>1
            %                 error('SymExpression objects do not allow nested indexing. Assign intermediate values to variables instead.');
            %             end
            
            
            switch Idx(1).type
                case '.'
                    B = builtin('subsref', L, Idx);
                  
                case '()'
                        
                    
                    switch numel(Idx.subs)
                        case 0
                            sstr = ['ToVectorForm[' L.s ']'];
                        case 1
                            
                            sstr = ['ToVectorForm[' L.s ']'];
                            % special case shortcut for L(:)
                            if ischar(Idx.subs{1}) && strcmp(Idx.subs{1},':')
                                sstr = [sstr,'[[;;]]'];
                            elseif isnumeric(Idx.subs{1})
                                sstr = [sstr,'[[Flatten@',mat2math(Idx.subs{1}),']]'];
                            else
                                error('The index is invalid.');
                            end
                            
                        case 2
                            ind = cell(1,2);
                            for i=1:2
                                if ischar(Idx.subs{i}) && strcmp(Idx.subs{i},':')
                                    ind{i} = ';;';
                                elseif isnumeric(Idx.subs{i})
                                    if isscalar(Idx.subs{i})
                                        ind{i} = num2str(Idx.subs{i});
                                    else
                                        ind{i} = eval_math(['Flatten@',mat2math(Idx.subs{i})]);
                                    end
                                else
                                    error('The index is invalid.');
                                end
                            end
                            
                            sstr = [L.s,'[[',ind{1},',',ind{2},']]'];
                        otherwise
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
        
        function M = char(A)
            % Convert scalar or array sym to string.
            %   CHAR(A) returns a string representation of the symbolic object A
            %   in MuPAD syntax.
            
            
            % Convert inputs to SymExpression
            A = SymExpression(A);
            
            M = eval_math(A.s);
        end
        
        obj = save(obj, file_path, file);
        file = export(obj, varargin);
        obj = load(obj, file_path, file);
    end
end