function obj = addJumpConstraint(obj, edge, src, tar, bounds)
    % Add jump constraints between the edge and neighboring two nodes
    % (source and target) 
    %
    % These constraints include the continuity of the states/time
    % variables, as well as system-specific discrete map constraint of the
    % guard dynamics, and user-specific constraints.
    %
    % Parameters:
    % src: the source node NLP @type TrajectoryOptimization
    % edge: the edge NLP @type TrajectoryOptimization
    % tar: the target node NLP @type TrajectoryOptimization
    
    
    %|@todo: 
    % - time 
    % - state
    % - callback system constraint
    % - based on event function, remove unnecessary event function
    % constraints from source domain
    
    % continuity of time
    t_s = SymVariable('ts',[2,1]);
    t_n = SymVariable('tn',[2,1]);
    t_cont = SymFunction('tContDomain',flatten(ts(2)-tn(1)),{t_s,t_n});
    
    % create a NlpFunction for 'edge' NLP, but use the NlpVariables from
    % 'src' and 'tar' NLPs.
    if src.Options.DistributeTimeVariable
        src_time_node = 1;
    else
        src_time_node = src.NumNode;
    end
    t_cstr = NlpFunction('Name','tContDomain',...
        'Dimension',1,...
        'lb', 0,...
        'ub', 0,...
        'Type','Linear',...
        'SymFun',t_cont,...
        'DepVariables',[src.OptVarTable.T(src_time_node);tar.OptVarTable.T(1)]);
    edge.addConstraint('tContDomain','first',t_cstr);
    
    % state continuity (src <-> edge)
    x_s = src.Plant.States.x;
    x_e = edge.Plant.States.xminus;
    x_cont_src = SymFunction(['xMinusCont_' edge.Name],x_s-x_e,{x_s,x_e});
    x_src_cstr = NlpFunction('Name',['xMinusCont_' edge.Name],...
        'Dimension',src.Plant.numState,...
        'lb', 0,...
        'ub', 0,...
        'Type','Linear',...
        'SymFun',x_cont_src,...
        'DepVariables',[src.OptVarTable.x(end);edge.OptVarTable.xminus(1)]);
    edge.addConstraint('xMinusCont','first',x_src_cstr);
    
    % state continuity (edge <-> tar)
    x_t = tar.Plant.States.x;
    x_e = edge.Plant.States.xplus;
    x_cont_tar = SymFunction(['xPlusCont_' edge.Name],x_e-x_t,{x_e,x_t});
    x_tar_cstr = NlpFunction('Name',['xPlusCont_' edge.Name],...
        'Dimension',tar.Plant.numState,...
        'lb', 0,...
        'ub', 0,...
        'Type','Linear',...
        'SymFun',x_cont_tar,...
        'DepVariables',[edge.OptVarTable.xplus(1);tar.OptVarTable.x(1)]);
    edge.addConstraint('xPlusCont','first',x_tar_cstr);
    
    if strcmp(edge.Plant.Type,'SecondOrder')
        % state derivative continuity (src <-> edge)
        dx_s = src.Plant.States.dx;
        dx_e = edge.Plant.States.dxminus;
        dx_cont_src = SymFunction(['dxMinusCont_' edge.Name],dx_s-dx_e,{dx_s,dx_e});
        dx_src_cstr = NlpFunction('Name',['dxMinusCont_' edge.Name],...
            'Dimension',src.Plant.numState,...
            'lb', 0,...
            'ub', 0,...
            'Type','Linear',...
            'SymFun',dx_cont_src,...
            'DepVariables',[src.OptVarTable.dx(end);edge.OptVarTable.dxminus(1)]);
        edge.addConstraint('dxMinusCont','first',dx_src_cstr);
        
        % state derivative continuity (edge <-> tar)
        dx_t = tar.Plant.States.dx;
        dx_e = edge.Plant.States.dxplus;
        dx_cont_tar = SymFunction(['dxPlusCont_' edge.Name],dx_e-dx_t,{dx_e,dx_t});
        dx_tar_cstr = NlpFunction('Name',['dxPlusCont_' edge.Name],...
            'Dimension',tar.Plant.numState,...
            'lb', 0,...
            'ub', 0,...
            'Type','Linear',...
            'SymFun',dx_cont_tar,...
            'DepVariables',[edge.OptVarTable.dxplus(1);tar.OptVarTable.dx(1)]);
        edge.addConstraint('dxPlusCont','first',dx_tar_cstr);
    end
    
    
    
    % the event function constraint for the source domain
    event_list = fieldnames(src.Plant.EventFuncs);
    event_idx = str_index(edge.Plant.EventName,event_list);
    event_obj = src.Plant.EventFuncs.(event_list{event_idx});
    event_obj.imposeNLPConstraint(edge);
    
    
    % call the system constraint callback method for the discrete dyamics
    addSystemConstraint(edge.Plant, edge, src, tar, bounds);
    
end