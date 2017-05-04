function obj = setDriftVector(obj, vf)
    % Set the drift vector field Fvec(x) or Fvec(x,dx) of the
    % system
    %
    % Parameters:
    %  vf: the f(x) @type cell
    
    % validate the inputs vf(x,dx)
    if ~iscell(vf), vf = {vf}; end
    obj.Fvec = cell(0);
    for i=1:numel(vf)
        assert((length(vf{i})==obj.numState) && isvector(vf{i}),...
            'The %d-th drift vector field should be a (%d x 1) column vector.',i,obj.numState);
        if isa(vf{i},'SymFunction')
            if strcmp(obj.Type,'SecondOrder') % second order system
                assert(length(vf{i}.Vars)==2 && vf{i}.Vars{1} == obj.States.x && vf{i}.Vars{2}==obj.States.dx,...
                    'The SymFunction (vf{%d}) must be a function of states (x) and (dx).',i);
            else % first order system
                assert(length(vf{i}.Vars)==1 && vf{i}.Vars{1} == obj.States.x,...
                    'The SymFunction (vf{%d}) must be a function of states (x).',i);
            end
            obj.Fvec = [obj.Fvec,vf(i)];
        else
            s_vf = SymExpression(vf{i});
            if strcmp(obj.Type,'SecondOrder') % second order system
                sfun_vf = SymFunction(['Fvec' num2str(i) '_' obj.Name],s_vf,{obj.States.x,obj.States.dx});
            else                         % first order system
                sfun_vf = SymFunction(['Fvec' num2str(i) '_' obj.Name],s_vf,{obj.States.x});
            end
            obj.Fvec = [obj.Fvec,{sfun_vf}];
        end
    end
    
    obj.FvecName_ = cellfun(@(f)f.Name, obj.Fvec,'UniformOutput',false);
end