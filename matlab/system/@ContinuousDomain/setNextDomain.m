function obj = setNextDomain(obj, next_domain)
    % setNextDomain - set next domain of current domain
    %
    % Copyright 2016 Georgia Tech, AMBER Lab
    % Author: Ayonga Hereid <ayonga@gatech.edu>
    
    % argument check
    narginchk(2, 2);
    
    % if the transition from the current domain to next domain involves
    % rigid impacts, then set the impact constraints to be holonomic
    % constraints of the next domain
    if obj.hasImpact && (next_domain.domainIndex ~= -1)
        if obj.nImpConstr == 0 
            %             obj.impConstrName = next_domain.holConstrName;
            %             obj.nImpConstr    = next_domain.nHolConstr;
            obj.impConstrJac  = next_domain.hol_constr_jac;
        end
    end
    
    
    %     nextDomain = struct();
    %     nextDomain.domainName  = next_domain.domainName;
    %     nextDomain.domainIndex = next_domain.domainIndex;
    %
    %     obj.nextDomain = nextDomain;

end