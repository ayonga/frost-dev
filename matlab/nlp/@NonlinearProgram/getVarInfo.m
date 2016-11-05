function [nVar, lowerbound, upperbound] = getVarInfo(obj)
    % The function returns the dimension, upper/lower limits of NLP
    % variables.
    %
    % Return values:
    %  nVar: the total dimension of all NLP variables @type
    %  integer
    %  lowerbound: the lower limits @type colvec
    %  upperbound: the upper limits @type colvec
    
    assert(~isempty(obj.varArray),['No variable is definied.\n',...
        'Please define NLP variables first.\n']);
    
    nVar = sum([obj.varArray.dimension]);
    
    lowerbound = vertcat(obj.varArray.lb);
    upperbound = vertcat(obj.varArray.ub);
    
end