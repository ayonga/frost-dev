function obj = setDriftVector(obj, vf)
    % Set the drift vector field Fvec(x) or Fvec(x,dx) of the
    % system
    %
    % Parameters:
    %  vf: the f(x) @type cell
    
    % validate the inputs vf(x,dx)
    if ~iscell(vf), vf = {vf}; end
    
    for i=1:numel(vf)
        assert((length(vf{i})==obj.numState) && isvector(vf{i}),...
            'The %d-th drift vector field should be a (%d x 1) column vector.',i,obj.numState);
        if isa(vf{i},'SymFunction')
            obj.Fvec = [obj.Fvec,vf(i)];
        else
            s_vf = SymExpression(vf{i});
            if ~isempty(obj.States.ddx) % second order system
                sfun_vf = SymFunction(['Fvec' num2str(i) '_' obj.Name],s_vf,{obj.States.x,obj.States.dx});
            else                         % first order system
                sfun_vf = SymFunction(['Fvec' num2str(i) '_' obj.Name],s_vf,{obj.States.x});
            end
            obj.Fvec = [obj.Fvec,{sfun_vf}];
        end
    end
    
    
end