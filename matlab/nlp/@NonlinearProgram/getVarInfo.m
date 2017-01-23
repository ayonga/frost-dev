function [nVar, lowerbound, upperbound] = getVarInfo(obj)
    % The function returns the dimension, upper/lower limits of NLP
    % variables.
    %
    % Return values:
    %  nVar: the total dimension of all NLP variables @type
    %  integer
    %  lowerbound: the lower limits @type colvec
    %  upperbound: the upper limits @type colvec
    
    assert(~isempty(obj.VariableArray),...
        'NonlinearProgram:emptyVarArray',...
        ['No variable has been definied.\n',...
        'Please define NLP variables first.\n']);
    
    
    
    nVar = sum(cellfun(@(x)x.Dimension, obj.VariableArray));     
    lowerbound = vertcat(cellfun(@(x)x.LowerBound, obj.VariableArray, 'UniformOutput', false));
    upperbound = vertcat(cellfun(@(x)x.UpperBound, obj.VariableArray, 'UniformOutput', false));
    
end