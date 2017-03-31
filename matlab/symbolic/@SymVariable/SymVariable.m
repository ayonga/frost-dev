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
    
    
    
    methods
        
        function obj = SymVariable(x, n)
            % The class constructor function
            %
            % Parameters:
            % x: name or prefix of the variable @type char
            % n: the dimension of th variable @type numeric
            
            % check the number of input arguments
            narginchk(0,2);
            
            
            
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
                            'the dimensions of the generated symbolic vector or matrix');
                        
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
        end
        
        
        
        
        
        
        
        
        
    end
end