function obj = addRD1Output(obj, act, phase_var, des_type, order)
    % Add state variables of the dynamical system
    %
    %
    % Parameters:
    % act: the actual output ya @type SymExpression
    % phase_var: the phase variable @type SymExpression
    % des_type: the function type of the desired outputs @type char
    % order: the order of the Bezier curve (des_type = 'Bezier')
    % @type integer
    %
    % @note if phase_var is empty, then we assume the phase variable is the
    % time.
    
    
    assert(isa(act,'SymExpression') && isscalar(act), ...
        'the actual output must be a scalar SymExpression object.');
    
    obj.RD1Output = struct;
    
    obj.RD1Output.Act = SymFunction(['y1act_',obj.Name],...
        tomatrix(act),obj.States.x);
    
    n_output = length(act);
    
    
    if ~isempty(obj.RD2Output)
        if isfield(obj.RD2Output,'Act')
            n_output_rd2 = length(obj.RD2Output.Act);
        else
            n_output_rd2 = 0;
        end
    else
        n_output_rd2 = 0;
    end
    
    assert(n_output + n_output_rd2<=obj.numControl,...
        'The total number of output cannot be greater than the number of control inputs.');
    
    t = SymVariable('t');
    
    if ~isempty(phase_var)
        assert(isa(phase_var,'SymExpression') && prod(size(phase_var))==1, ...
            'the actual output must be a vector SymExpression object.'); %#ok<PSIZE>
        
        obj.RD1Output.PhaseVar = SymFunction(['y1tau_',obj.Name],...
            tovector(phase_var),{obj.States.x});
        obj.RD1Output.Type = 'StateBased';
    else
        obj.RD1Output.PhaseVar = SymFunction(['y1tau_',obj.Name],t,{t});
        obj.RD1Output.Type = 'TimeBased';
    end
    
    switch des_type
        case 'Bezier'
            n_param = order + 1;
            N = num2str(order);
            str = ['Table[Sum[Symbol["a$" <> ToString[i]<>"$"<>ToString[j+1]]*Binomial[' N ',j]*t^j*(1-t)^(' N '-j),{j,0,' N '}],{i,1,' num2str(n_output) '}]'];
            expr = SymExpression(str);
            
            % expr = subs(expr,t,obj.RD1Output.PhaseVar);
            v = SymVariable('v',[n_output,n_param]);
            obj.addParam('v',v);
            obj.RD1Output.Des = SymFunction(['y1des_',obj.Name],...
                tomatrix(expr),{t,obj.States.x,obj.Params.v});
        otherwise
            error('Undefined function type for the desired output.');

    end
end
