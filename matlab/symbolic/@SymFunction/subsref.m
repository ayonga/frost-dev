function B = subsref(A,Idx)
    % Subscripted reference for a symbolic function.
    %     B = SUBSREF(A,Idx) is called for the syntax A(I).  S is a structure array
    %     with the fields:
    %         type -- string containing '()' specifying the subscript type.
    %                 Only parenthesis subscripting is allowed.
    %         subs -- Cell array or string containing the actual subscripts.
    %
    
    if length(Idx)>1
        error(message('symbolic:sym:NestedIndex'));
    end
    
    
    switch Idx.type
        case '.'
            B = builtin('subsref', L, Idx);
            
        case '()'
            
            Avars = A.vars;
            inds = Idx.subs;
            if length(inds) ~= length(Avars)
                error('SymFunction:subsref',...
                    'Symbolic function expected %d inputs and received %d.', length(Avars), length(inds));
            end
            strs = cellfun(@ischar,inds);
            if any(strcmp(inds(strs),':'))
                error('SymFunction:subsref',...
                    'Symbolic function indexing evaluates the function at the inputs.');
            end
            % create a new object with the evaluated string
            B = feval(A,inds{:});
        case '{}'
            % No support for indexing using '{}'
            error('SymFunction:subsref', ...
                'Cell indexing and structure indexing are not implemented for symbolic functions.');
        otherwise
            error('SymFunction:subsref', ...
                'Cell indexing and structure indexing are not implemented for symbolic functions.');
    end
    
    
end