function nlp = ConfigureCollisionConstraints(nlp, planeobstacleobject)

    spatula_specs = getSpatulaSpecs();
    
    corners = getGrillAndTableSpecs();
    grill_box = corners.grill_box;
    table_box = corners.table_box;
    
    Region = struct();
    Region.nSubRegions = 2;
    
%     planeobstacleobject = struct();
        Region = struct();
        Region.nSubRegions = 2;
        % this is grill subregion
        Region.SubRegion(1).nPlanes = 4;
        Region.SubRegion(1).Planes(1).normal = [1,0,0];
        Region.SubRegion(1).Planes(1).point = grill_box.p_min;
        Region.SubRegion(1).Planes(2).normal = [0,-1,0];
        Region.SubRegion(1).Planes(2).point = grill_box.p_max;
        Region.SubRegion(1).Planes(3).normal = [-1,0,0];
        Region.SubRegion(1).Planes(3).point = grill_box.p_max;
        Region.SubRegion(1).Planes(4).normal = [0,1,0];
        Region.SubRegion(1).Planes(4).point = grill_box.p_min;
        % this is table subregion
        Region.SubRegion(2).nPlanes = 4;
        Region.SubRegion(2).Planes(1).normal = [1,0,0];
        Region.SubRegion(2).Planes(1).point = table_box.p_min;
        Region.SubRegion(2).Planes(2).normal = [0,-1,0];
        Region.SubRegion(2).Planes(2).point = table_box.p_max;
        Region.SubRegion(2).Planes(3).normal = [-1,0,0];
        Region.SubRegion(2).Planes(3).point = table_box.p_max;
        Region.SubRegion(2).Planes(4).normal = [0,1,0];
        Region.SubRegion(2).Planes(4).point = grill_box.p_min;
        
        plant  = nlp.Plant;
%     nstate = plant.numState;
%     nPlanes = planeobstacleobject.nPlanes;
    nSubRegions = Region.nSubRegions;
    
    %% get the sym variables
    x = plant.States.x;

    spatula_link = plant.Links(getLinkIndices(plant, 'link_6'));

    spatula_tool_frame = spatula_link.Reference;

    spatula = CoordinateFrame(...
        'Name','SpatulaTool',...
        'Reference',spatula_tool_frame,...
        'Offset',spatula_specs.Offset,... 
        'R',spatula_specs.R ... 
        );
    
    
    p_spatula = getCartesianPosition(plant,spatula);

%     %% create the lambda struct inorder to create collision checker
%     nlambda = nstate*nlines;
%     lmbda = SymVariable('lmbda',[nlambda,1]);
%    
%     % creating lambda struct
%     lmbda_var = struct();
%     lmbda_var.Name = 'lmbda';
%     lmbda_var.Dimension = nlambda;
%     lmbda_var.lb = zeros(nlambda,1);
%     lmbda_var.ub = ones(nlambda,1);

%     nlp.addVariable('lmbda', 'all', lmbda_var);
    %% create the w struct inorder to create collision checker
%     nw = nPlanes*(nstate+1);
    nw = nSubRegions;
%     nw = 2;
    w = SymVariable('w',[nw,1]);
   
    % creating lambda struct
    w_var = struct();
    w_var.Name = 'w';
    w_var.Dimension = nw;
    w_var.lb = zeros(nw,1);
    w_var.ub = ones(nw,1)*Inf;

    nlp.addVariable('w', 'all', w_var);
    
%     for i = 1:nSubRegions
%         SubRegion = Region.SubRegion(i);
%         for j = 1:SubRegion.nPlanes
%             point = SubRegion.Planes(j).point;
%             normal = SubRegion.Planes(j).normal;
%             if i == 2
%                 collision_linear_constraints = (p_spatula - point)*normal' + w;
%             else
%                 collision_linear_constraints = (p_spatula - point)*normal' + (-w+100);
%             end
%                 
%             collision_linear_constraints_func = SymFunction(['collision_constraints_',...
%                 num2str(i),...
%                 num2str(j),...
%                 plant.Name],collision_linear_constraints,{x,w});
%             
%             addNodeConstraint(nlp,collision_linear_constraints_func,{'x','w'},'all',0,Inf,'Linear');
%         end
%     end
    
%     w_sum = w(1)+w(2);
% %     w_sum = -w+100;
%     w_sum_func = SymFunction(['collision_var_sum_' plant.Name],w_sum,{w});
%     addNodeConstraint(nlp,w_sum_func,{'w'},'all',100,Inf,'Linear');
%     w_mult = w(1)*w(2);
%     w_mult_func = SymFunction(['collision_var_mult_' plant.Name],w_mult,{w});
%     addNodeConstraint(nlp,w_mult_func,{'w'},'all',0,1,'Nonlinear');
    
    
    %% okay having added the lambda struct now get the joint positions
    % every vertical column in this variable below is x,y,z position of a
    % specific point. Point is indexed by rows. So six links will have 6
    % points == joint points
%     jointcart_positions = cell(nstate+1,1);
%     joint_link_lengths_squared  = cell(nstate,1);
    
%     for i=1:nstate+1
%         if i<nstate+1
%             parent_link = plant.Links(getLinkIndices(plant, ['link_',num2str(i)]));
%             parent_frame = parent_link.Reference;
%             
%             parent = CoordinateFrame(...
%                 'Name','ChildTool',...
%                 'Reference',parent_frame,...
%                 'Offset',[0 0 0],...
%                 'R',[0 0 0]...
%                 );
%             
%         
%         else
%             parent_link = plant.Links(getLinkIndices(plant, ['link_',num2str(i-1)]));
%             parent_frame = parent_link.Reference;
%             
%             parent = CoordinateFrame(...
%                 'Name','ChildTool',...
%                 'Reference',parent_frame,...
%                 'Offset',[-0.014 0.0 0.208],...
%                 'R',[0,-2 * pi/3,-23*pi/180]...
%                 );
%             
%         end
%         
%         p_parent = getCartesianPosition(plant,parent);
% 
%         jointcart_positions{i} = p_parent;
%         
% %         % cartesian position of  each joint in the workspace
% % %         v = matlab.lang.makeValidName(['jointcart_link_',num2str(i)]);
% % %         eval([v '= p_parent']);
% %         if i>1
% %             if i<nstate+1
% %                 joint_link_lengths_squared{i-1} = sum(plant.Joints(i).Offset.^2);
% %             else
% %                 joint_link_lengths_squared{i-1} = sum(parent.Offset.^2);
% %             end
% %         end
% 
%     end
    
%% now get the positions of the end points of the lines. these very important
%     obstacle_points = cell(nPlanes*2,1); % for starting and end points
    
%     for i=1:nPlanes
%         obstacle_points{2*(i-1)+1} = planeobstacleobject.Lines(i).StartPoint;
%         obstacle_points{2*(i-1)+2} = planeobstacleobject.Lines(i).EndPoint;
%     end

%%  now create the new constraints this is the main body of the code
    % first use the line obstacle object to obtain the set of points (lines)
%     for i=1:nlines 
%         pos_start = lineobstacleobject.Lines(i).StartPoint;
%         
%         pos_end = lineobstacleobject.Lines(i).EndPoint;
%         
%         line_length_sq = sum((pos_start - pos_end).^2);
%         % with the starting and ending position get the lambda for each
%         % link
%         for j=1:nstate
% 
% %             % joint position jth link
%             p_parent = jointcart_positions{j};
%             % the sum of the distances
% 
%             sumdistance_sca = sum([tovector((p_parent - pos_start).^2);...
%                               tovector((p_parent - pos_end).^2); ...
%                               -line_length_sq]);
%                           
%             collision_func = SymFunction(['CollisionJointtoLineSca_',...
%                                            num2str(j),...
%                                            num2str(i),...
%                                            plant.Name],sumdistance_sca,{x});
% 
%             addNodeConstraint(nlp,collision_func,{'x'},'all',0,Inf,'Nonlinear');
%         end
%     end
%     
%     for i=1:nstate
%         % joint position jth link
%         p_parent = jointcart_positions{i};
%         % joint position jth link
%         p_child = jointcart_positions{i+1};
%  
%         
%         % link
%         for j=1:nlines*2
% 
%             line_point_position = obstacle_points{j};
%         
%             % the sum of the distances
% 
%             sumdistance_sca = sum([tovector((line_point_position - p_parent).^2); ...
%                               tovector((line_point_position - p_child).^2); ...
%                               -joint_link_lengths_squared{i}]);
%                           
%             collision_func = SymFunction(['CollisionLinetoJointSca_',...
%                                            num2str(j),...
%                                            num2str(i),...
%                                            plant.Name],sumdistance_sca,{x});
% 
%             addNodeConstraint(nlp,collision_func,{'x'},'all',0,Inf,'Nonlinear');
%         end
%     end
    %% the code for line line intersect -- shortest distance between the two
%      for j=1:1
%          % joint position jth link
%          p_parent = jointcart_positions{j};
%          % p_child  = jointcart_positions{j+1};
%          % the sum of the distances
% 
%          for i=1:nPlanes 
%          %         pos_start = planeobstacleobject.Lines(i).StartPoint;
%          %         pos_end = planeobstacleobject.Lines(i).EndPoint;
%              normal = planeobstacleobject.Planes(i).normal;
%              point  = planeobstacleobject.Planes(i).point;
%             %         line_length_sq = sum((pos_start - pos_end).^2);
%             %         line_length_sq = sum((pos_start - pos_end).^2);
%             % with the starting and ending position get the lambda for each
%             % link
%     
% %             areasq = BertSchneiderFormula(p_parent,p_child,...
% %                                         SymExpression(pos_start),...
% %                                         SymExpression(pos_end),...
% %                                         SymExpression(joint_link_lengths_squared{j}),...
% %                                         SymExpression(line_length_sq));
% %                                         
% %            sumdistance_sca = areasq(1);
% %             [pa,pb,pa1,pa2,pb3,pb4] = LineLineIntersect(p_parent,p_child,SymExpression(pos_start),SymExpression(pos_end));
% %             sumdistance_sca = (pa(1)-pb(1)).^2 + (pa(2)-pb(2)).^2 + (pa(3)-pb(3)).^2 + ...
% %                                pa1(1).^2+pa2(1).^2+pa1(2).^2+pa2(2).^2+pa1(3).^2+pa2(3).^2+...
% %                                pb3(1).^2+pb4(1).^2+pb3(2).^2+pb4(2).^2+pb3(3).^2+pb4(3).^2-...
% %                                -joint_link_lengths_squared{j}-line_length_sq;
%             wlink = (p_parent - point)*normal' + 1000*w(nPlanes*(j-1)+i);
% 
%             wlink_func = SymFunction(['WLink_Sca',...
%                                         num2str(i),...
%                                         num2str(j),...
%                                         plant.Name],wlink,{x,w});
% 
% %             collision_func = SymFunction(['LineLineIntersectSca_',...
% %                                            num2str(i),...
% %                                            num2str(j),...
% %                                            plant.Name],sumdistance_sca,{x});
% 
%             addNodeConstraint(nlp,wlink_func,{'x','w'},'all',0.00,Inf,'Nonlinear');
%          end
%         
%         indexingofw = 1:nPlanes;
%         wlinkindex = indexingofw + (j-1)*nPlanes;
%         wlinklogic = sum(w(wlinkindex));
%         wlinklogic_func = SymFunction(['WlinkLogic_Sca',...
%                                         num2str(j),...
%                                         plant.Name],wlinklogic,{w});
% %         addNodeConstraint(nlp,wlinklogic_func,{'w'},'all',-0.01,3.1,'Linear');
%         
%     end
    
    
    
end
