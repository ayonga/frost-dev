function [A_G,A_G_dot] = calcCMM(obj, q, dq)
    % 
    % 
    % Note: spatial twist = [linear; angular]
    
    
    cmm_all = cellfun(@(x)feval(x.Name, q), obj.CMMat, 'UniformOutput',false);
    
    A_G = zeros(6,obj.Dimension);
    for i=1:numel(cmm_all)
        A_G = A_G + cmm_all{i};        
    end
    
    if nargout > 1
        %         cmm_dot_all = cellfun(@(x)feval(x.Name, q, dq), obj.CMMatDot, 'UniformOutput',false);
        %
        %         A_G_dot = zeros(6,obj.Dimension);
        %         for i=1:numel(cmm_dot_all)
        %             A_G_dot = A_G_dot + cmm_dot_all{i};
        %         end
        A_G_dot = [];
    end
    
end

