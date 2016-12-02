function dofs = configureDoFs(obj, model, base_dofs)
    % Configure the degrees of freedom of the rigid-body system
    %
    % Parameters:
    %  model: the URDF robot model @type struct
    %
    % Return values:
    %  obj:   the object of this class
    
    
    
    dofs(obj.n_base_dofs) = struct();

    if obj.n_base_dofs ~= 0        
        for i = 1:obj.n_base_dofs
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
            dofs(i).effort = base_dofs.effort(i);
            dofs(i).lower = base_dofs.lower(i);
            dofs(i).upper = base_dofs.upper(i);
            dofs(i).velocity = base_dofs.velocity(i);
        end
        
    end
    
    body_dofs = rmfield(model.joints,{'origin','parent','child'});
    
    
    dofs = [dofs,body_dofs];

end
