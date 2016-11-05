function [dimOptVar, lb, ub] = getVarInfos(obj)
    % The function returns the dimension, upper/lower limits of NLP
    % variables.
    %
    % Return values:
    %  dimOptVar: the total dimension of all NLP variables @type
    %  integer
    %  lb: the lower limits @type colvec
    %  ub: the upper limits @type colvec
    
    assert(~isempty(obj.optVars),['No variable is definied.\n',...
        'Please define NLP variables first.\n']);
    
    dimOptVar = sum([obj.optVars.dimension]);
    
    lb = vertcat(obj.optVars.lb);
    ub = vertcat(obj.optVars.ub);
    
end