function obj = addRD2Output(obj, act, phase_var, des_type, order)
    % Add relative degree two outputs
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
    
    assert(isa(act,'SymExpression') && isvector(act), ...
        'the actual output must be a vector SymExpression object.');
    
    obj.RD2Output = struct;
    
    obj.RD2Output.Act = SymFunction(['y2act_',obj.Name],...
        tomatrix(act),obj.States.x);
    
    n_output = length(act);
    
    if ~isempty(obj.RD1Output)
        if isfield(obj.RD1Output,'Act')
            n_output_rd1 = length(obj.RD1Output.Act);
        else
            n_output_rd1 = 0;
        end
    else
        n_output_rd1 = 0;
    end
    
    assert(n_output + n_output_rd1<=obj.numControl,...
        'The total number of output cannot be greater than the number of control inputs.');
    
    t = SymVariable('t');
    
    if ~isempty(phase_var)
        assert(isa(phase_var,'SymExpression') && prod(size(phase_var))==1, ...
            'the actual output must be a vector SymExpression object.'); %#ok<PSIZE>
        
        obj.RD2Output.PhaseVar = SymFunction(['y2tau_',obj.Name],...
            tovector(phase_var),{obj.States.x});
        obj.RD2Output.Type = 'StateBased';
    else
        obj.RD2Output.PhaseVar = SymFunction(['y2tau_',obj.Name],t,{t});
        obj.RD2Output.Type = 'TimeBased';
    end
    
    switch des_type
        case 'Bezier'
            n_param = order + 1;
            N = num2str(order);
            str = ['Table[Sum[Symbol["a$" <> ToString[i]<>"$"<>ToString[j+1]]*Binomial[' N ',j]*t^j*(1-t)^(' N '-j),{j,0,' N '}],{i,1,' num2str(n_output) '}]'];
            expr = SymExpression(str);
            
            % expr = subs(expr,t,obj.RD2Output.PhaseVar);
            a = SymVariable('a',[n_output,n_param]);
            obj.addParam('a',a);
            obj.RD2Output.Des = SymFunction(['y2des_',obj.Name],...
                tomatrix(expr),{t,obj.Params.a});
        otherwise
            error('Undefined function type for the desired output.');

    end
end
