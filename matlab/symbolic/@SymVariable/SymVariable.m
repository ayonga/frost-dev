classdef SymVariable < SymExpression
    % An object that represents a list of symbolic variables
    %
    % Copyright (c) 2016-2017, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    properties (Access=protected)
        % A list of character label of the symbolic variables
        %
        % @type cellstr
        label
    end
    
    
    methods
        
        function obj = SymVariable(x, n, label)
            % The class constructor function
            %
            % Parameters:
            % x: name or prefix of the variable @type char
            % n: the dimension of th variable @type numeric
            % label: the label of the variables @type cellstr
            % 
            % check the number of input arguments
            narginchk(0,3);
            
            
            
            if nargin == 0 || isempty(x)
                str = [];
            else
                
                if isequal(class(x),'SymVariable')
                    str = x.f;
                elseif isequal(class(x),'SymExpression') %private use only
                    str = x.f;
                elseif iscell(x)
                    str = cell2tensor(x,'ConvertString',false);
                else
                
                    assert(ischar(x),...
                        'SymVaraible:invalidSymbol',...
                        ['The first argument must be a character vector specifying the base name for',...
                        'vector or matrix elements. It must be a valid variable name.']);
                    
                    
                    assert(isempty(regexp(x, '\W', 'once')) || ~isempty(regexp(x, '\$', 'once')),...
                        'SymExpression:invalidSymbol', ...
                        'Invalid symbol string, can NOT contain special characters.');
                    
                    assert(isempty(regexp(x, '_', 'once')),...
                        'SymExpression:invalidSymbol', ...
                        'Invalid symbol string, can NOT contain ''_''.');
                    
                    assert(~isempty(regexp(x, '^[a-z]\w*', 'match')),...
                        'SymExpression:invalidSymbol', ...
                        'First letter must be lowercase character.');
                    
                    sstr = eval_math(['Symbol[',str2mathstr(x),']']);
                    
                    if ~strcmp(sstr, x)
                        error('SymExpression:invalidSymbol',...
                            'The given symbol has already been already assigned a value.');
                    end
                    
                    
                    
                    
                    if nargin > 1
                        assert(isnumeric(n),...
                            'SymExpression:invalidDimension',...
                            'The second argument must be numeric values that specify',...
                            'the dimensionssetLabel of the generated symbolic vector or matrix');
                        
                        switch numel(n)
                            case 0
                                str = x;
                            case 1
                                str = eval_math([' Map[Symbol,Table[ToString[', x,...
                                    ']<>"$"<>ToString[i], {i, ', num2str(n(1)), '}]]']);
                            case 2
                                str = eval_math([' Map[Symbol,Table[',...
                                    'ToString[', x, ']<>"$"<>ToString[i]<>"$"<>ToString[j],',...
                                    '{i, ', num2str(n(1)), '}, {j, ', num2str(n(2)), '}],{2}]']);
                            otherwise
                                error('SymVariable does NOT support numel(n) > 2');
                        end
                    else
                        str = x;
                    end
                end
            end  
            obj = obj@SymExpression(str);
            
            
            if nargin == 3
                obj.setLabel(n, label);                
            end
        end
        
    end
    
    methods (Hidden = true)
        
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
                            L.label = subsasgn(L.label,Idx,R);
                        else
                            eval_math([sstr '= ' B.s ';']);
                        end
                    elseif isnumeric(Idx.subs{1})
                        ids = Idx.subs{1};
                        if isempty(R)
                            eval_math([sstr '=ToVectorForm[' sstr '];']);
                            eval_math([sstr '=Delete[' sstr ',' mat2math(ids(:)) '];']);
                            L.label = subsasgn(L.label,Idx,R);
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
            
            
            % if length(Idx)>1
            %    error('SymExpression objects do not allow nested indexing. Assign intermediate values to variables instead.');
            % end
            
            
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
                            elseif ischar(Idx.subs{1})
                                label_str = Idx.subs{1};
                                ind = find(cellfun(@(x)~isempty(x),strfind(L.label,label_str)));
                                sstr = [sstr,'[[Flatten@',mat2math(ind),']]'];
                            elseif iscellstr(Idx.subs{1})
                                label_str = Idx.subs{1};
                                ind = zeros(1,numel(label_str));
                                for i=1:numel(label_str)
                                    ind(i) = find(cellfun(@(x)~isempty(x),strfind(L.label,label_str{i})));
                                end
                                sstr = [sstr,'[[Flatten@',mat2math(ind),']]'];
                                
                            else
                                error('The index is invalid.');
                            end
                            
                        case 2
                            ind = cell(1,2);
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
        
        
        
        
        
    end
end