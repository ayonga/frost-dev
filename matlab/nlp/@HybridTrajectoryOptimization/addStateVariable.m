function obj = addStateVariable(obj, phase, model)
    % Adds state variables as the NLP decision variables to the problem
    %
    % Parameters:
    % phase: the index of the phase (domain) @type integer
    % model: the rigid body model of the robot @type RigidBodyModel
    
    num_node = obj.Phase{phase}.NumNode;
    col_names = obj.Phase{phase}.OptVarTable.Properties.VariableNames;
    
    % state variables are defined at all collocation nodes
    nodeList = 1:1:num_node;
    q = cell(1,num_node);
    dq = cell(1,num_node);
    ddq = cell(1,num_node);
    
    for i=nodeList
        % joint (q)
        q{i} = NlpVariable('Name', 'q', 'Dimension', model.nDof, ...
            'lb', [model.Dof.lower]', ...
            'ub', [model.Dof.upper]');
        % joint velocity (dq)
        dq{i} = NlpVariable('Name', 'dq', 'Dimension', model.nDof, ...
            'lb', -[model.Dof.velocity]', ...
            'ub', [model.Dof.velocity]');
        
        % joint acceleration (ddq)
        ddq{i} = NlpVariable('Name', 'ddq', 'Dimension', model.nDof, ...
            'lb', -1e4, ...
            'ub', 1e4);
        
    end
    
    
    % add to the decision variable table
    obj.Phase{phase}.OptVarTable = [...
        obj.Phase{phase}.OptVarTable;...
        cell2table(q,'VariableNames',col_names,'RowNames',{'q'});...
        cell2table(dq,'VariableNames',col_names,'RowNames',{'dq'});...
        cell2table(ddq,'VariableNames',col_names,'RowNames',{'ddq'})];


end