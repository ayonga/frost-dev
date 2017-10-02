function obj = addJumpConstraint(obj, edge, src, tar, bounds, varargin)
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
    % bounds: the boundary values @type struct
    % varargin: extra argument @type varargin
    
    
    
    %% continuity of time
    t_s = SymVariable('ts',[2,1]);
    t_n = SymVariable('tn',[2,1]);
    t_cont = SymFunction('tContDomain',flatten(t_s(2)-t_n(1)),{t_s,t_n});
    
    % create a NlpFunction for 'edge' NLP, but use the NlpVariables from
    % 'src' and 'tar' NLPs.
    if src.Options.DistributeTimeVariable
        src_time_node = src.NumNode;
    else
        src_time_node = 1;
    end
    t_cstr = NlpFunction('Name','tContDomain',...
        'Dimension',1,...
        'lb', 0,...
        'ub', 0,...
        'Type','Linear',...
        'SymFun',t_cont,...
        'DepVariables',[src.OptVarTable.T(src_time_node);tar.OptVarTable.T(1)]);
    edge.addConstraint('tContDomain','first',t_cstr);
    
    %% state continuity (src <-> edge)
    x_s = src.Plant.States.x;
    x_e = SymVariable('xp',size(x_s));
    x_cont_src = SymFunction(['xMinusCont_' edge.Name],x_s-x_e,{x_s,x_e});
    x_src_cstr = NlpFunction('Name',['xMinusCont_' edge.Name],...
        'Dimension',src.Plant.numState,...
        'lb', 0,...
        'ub', 0,...
        'Type','Linear',...
        'SymFun',x_cont_src,...
        'DepVariables',[src.OptVarTable.x(end);edge.OptVarTable.x(1)]);
    edge.addConstraint('xMinusCont','first',x_src_cstr);
    
    %% state continuity (edge <-> tar)
    x_t = tar.Plant.States.x;
    x_e = edge.Plant.States.xn;
    x_cont_tar = SymFunction(['xPlusCont_' edge.Name],x_e-x_t,{x_e,x_t});
    x_tar_cstr = NlpFunction('Name',['xPlusCont_' edge.Name],...
        'Dimension',tar.Plant.numState,...
        'lb', 0,...
        'ub', 0,...
        'Type','Linear',...
        'SymFun',x_cont_tar,...
        'DepVariables',[edge.OptVarTable.xn(1);tar.OptVarTable.x(1)]);
    edge.addConstraint('xPlusCont','first',x_tar_cstr);
    
    if strcmp(edge.Plant.Type,'SecondOrder')
        %% state derivative continuity (src <-> edge)
        dx_s = src.Plant.States.dx;
        dx_e = SymVariable('xp',size(x_s));
        dx_cont_src = SymFunction(['dxMinusCont_' edge.Name],dx_s-dx_e,{dx_s,dx_e});
        dx_src_cstr = NlpFunction('Name',['dxMinusCont_' edge.Name],...
            'Dimension',src.Plant.numState,...
            'lb', 0,...
            'ub', 0,...
            'Type','Linear',...
            'SymFun',dx_cont_src,...
            'DepVariables',[src.OptVarTable.dx(end);edge.OptVarTable.dx(1)]);
        edge.addConstraint('dxMinusCont','first',dx_src_cstr);
        
        %% state derivative continuity (edge <-> tar)
        dx_t = tar.Plant.States.dx;
        dx_e = edge.Plant.States.dxn;
        dx_cont_tar = SymFunction(['dxPlusCont_' edge.Name],dx_e-dx_t,{dx_e,dx_t});
        dx_tar_cstr = NlpFunction('Name',['dxPlusCont_' edge.Name],...
            'Dimension',tar.Plant.numState,...
            'lb', 0,...
            'ub', 0,...
            'Type','Linear',...
            'SymFun',dx_cont_tar,...
            'DepVariables',[edge.OptVarTable.dxn(1);tar.OptVarTable.dx(1)]);
        edge.addConstraint('dxPlusCont','first',dx_tar_cstr);
    end
    
    
    
    %% the event function constraint for the source domain
    event_list = fieldnames(src.Plant.EventFuncs);  % all events
    if ~isempty(event_list)
        % find the index of the event associated with the edge
        event_idx = str_index(edge.Plant.EventName,event_list);
        % extract the event function object using the index
        event_obj = src.Plant.EventFuncs.(event_list{event_idx});
        % impose the NLP constraints (unilateral constraints)
        event_obj.imposeNLPConstraint(src);
        % update the upper bound at the last node to be zero (to ensure equality)
        event_cstr_name = event_obj.ConstrExpr.Name;
        updateConstrProp(src,event_cstr_name,'last','ub',0);
    end
    
    %% call the system constraint callback method for the discrete dyamics
    plant = edge.Plant;
    plant.UserNlpConstraint(edge, src, tar, bounds, varargin{:});
end