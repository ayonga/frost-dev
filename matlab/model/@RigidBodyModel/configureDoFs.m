function dofs = configureDoFs(obj, model, base_dofs)
    % Configure the degrees of freedom of the rigid-body system
    %
    % Parameters:
    %  model: the URDF robot model @type struct
    %
    % Return values:
    %  obj:   the object of this class
    
    
    
    dofs(obj.nDof) = struct();

    if obj.nBaseDof ~= 0        
        for i = 1:obj.nBaseDof
            switch base_dofs.axis{i}
                case {'Px','px'}
                    dofs(i).name = 'BasePosX';
                    dofs(i).type = 'prismatic';
                    dofs(i).axis = [1,0,0];
                case 'Py'
                    dofs(i).name = 'BasePosY';
                    dofs(i).type = 'prismatic';
                    dofs(i).axis = [0,1,0];
                case {'Pz','py'}
                    dofs(i).name = 'BasePosZ';
                    dofs(i).type = 'prismatic';
                    dofs(i).axis = [0,0,1];
                case 'Rx'
                    dofs(i).name = 'BaseRotX';
                    dofs(i).type = 'revolute';
                    dofs(i).axis = [1,0,0];
                case {'Ry','r'}
                    dofs(i).name = 'BaseRotY';
                    dofs(i).type = 'revolute';
                    dofs(i).axis = [0,1,0];
                case 'Rz'
                    dofs(i).name = 'BaseRotZ';
                    dofs(i).type = 'revolute';
                    dofs(i).axis = [0,0,1];
            end
            dofs(i).minEffort = 0;
            dofs(i).maxEffort = 0;
            dofs(i).minPos = base_dofs.lower(i);
            dofs(i).maxPos = base_dofs.upper(i);
            dofs(i).minVel = base_dofs.minVelocity(i);
            dofs(i).maxVel = base_dofs.maxVelocity(i);
            dofs(i).minAcc = -100;
            dofs(i).maxAcc = -100;
        end
        
    end
    
    for i=1:(obj.nDof - obj.nBaseDof)
        dofs(i+obj.nBaseDof).name = model.joints(i).name;
        dofs(i+obj.nBaseDof).type = model.joints(i).type;
        dofs(i+obj.nBaseDof).axis = model.joints(i).axis;
        dofs(i+obj.nBaseDof).minEffort = -model.joints(i).effort;
        dofs(i+obj.nBaseDof).maxEffort = model.joints(i).effort;
        dofs(i+obj.nBaseDof).minPos = model.joints(i).lower;
        dofs(i+obj.nBaseDof).maxPos = model.joints(i).upper;
        dofs(i+obj.nBaseDof).minVel = -model.joints(i).velocity;
        dofs(i+obj.nBaseDof).maxVel = model.joints(i).velocity;
        dofs(i+obj.nBaseDof).minAcc = -1000;
        dofs(i+obj.nBaseDof).maxAcc = -1000;
        
    end
    
    % body_dofs = rmfield(model.joints,{'origin','parent','child'});
    
    
    % dofs = [dofs,body_dofs];

end
