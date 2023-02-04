function [name, links, joints, transmissions] = load_urdf(urdf_file, round_number)
    % This function parse the ROS URDF file
    %
    % @note At this moment, this parser only support the 'link' and 'joint'
    % elements in the URDF file. More options are coming soon ...
    %
    % Return values:
    % name: the name of the robot model @type char
    % links: an array of rigid links structure @type structure
    % joints an array of rigid joints structure @type structure
    
    arguments
        urdf_file char {mustBeFile}
        round_number double {mustBeInteger,mustBePositive} = 6
    end
    
    urdf = xmlread(urdf_file);
    
    xml_robot = urdf.getElementsByTagName('robot').item(0);
    assert(~isempty(xml_robot),['The provided URDF file does not contains ',...
        'the proper robot element. Please provide a valid URDF file.']);
    
    name   = char(xml_robot.getAttribute('name'));
    
    
    % extract rigid links
    xml_links = xml_robot.getElementsByTagName('link');
    
    
    
    num_links = xml_links.getLength();
    links = struct();
    index = 1;
    for i=0:num_links-1
        xml_link = xml_links.item(i);
        if xml_link.hasChildNodes
            
            links(index).Name = char(xml_link.getAttribute('name'));
            inertial = xml_link.getElementsByTagName('inertial').item(0);
            origin = inertial.getElementsByTagName('origin').item(0);
            mass   = inertial.getElementsByTagName('mass').item(0);
            inertia   = inertial.getElementsByTagName('inertia').item(0);
            
            
            ixx = round(str2double(inertia.getAttribute('ixx')),round_number);
            ixy = round(str2double(inertia.getAttribute('ixy')),round_number);
            ixz = round(str2double(inertia.getAttribute('ixz')),round_number);
            iyy = round(str2double(inertia.getAttribute('iyy')),round_number);
            iyz = round(str2double(inertia.getAttribute('iyz')),round_number);
            izz = round(str2double(inertia.getAttribute('izz')),round_number);
            
            links(index).Mass = round(str2double(mass.getAttribute('value')),round_number);
            %%% To handle the case where inertial frame is the same as body
            % frame. (in URDF, this is normally ignored)
            try
               links(index).P = round(str2num(origin.getAttribute('xyz')),round_number);
               rpy = str2num(origin.getAttribute('rpy'));
            catch
               links(index).P = zeros(3,1);
               rpy = zeros(3,1);
            end
           
            links(index).R = rpy2rot(rpy);
            links(index).Inertia = [...
                ixx, ixy, ixz; 
                ixy, iyy, iyz; 
                ixz, iyz, izz];
            
            index = index + 1;
        end
        
    end
    
    
    
    % extract joints
    xml_joints = xml_robot.getElementsByTagName('joint');    
    num_joints = xml_joints.getLength();
    joints = struct();
    index = 1;
    for i=0:num_joints-1
        xml_joint = xml_joints.item(i);
        
        if xml_joint.hasChildNodes
            if isempty(char(xml_joint.getAttribute('type')))
                continue;
            end
            joints(index).Name = char(xml_joint.getAttribute('name'));
            joints(index).Type = char(xml_joint.getAttribute('type'));
            
            origin = xml_joint.getElementsByTagName('origin').item(0);
            axis = xml_joint.getElementsByTagName('axis').item(0);
            parent = xml_joint.getElementsByTagName('parent').item(0);
            child = xml_joint.getElementsByTagName('child').item(0);
            
            
            joints(index).P = round(str2num(origin.getAttribute('xyz')),round_number); %#ok<*ST2NM>
            rpy = str2num(origin.getAttribute('rpy'));
            if isempty(rpy)
                rpy = zeros(3,1);
            end
            joints(index).R = rpy2rot(rpy);
            joints(index).Parent = char(parent.getAttribute('link'));
            joints(index).Child  = char(child.getAttribute('link'));
            
            %             if ~strcmp(joints(index).Type, 'fixed')
            joints(index).Axis = str2num(axis.getAttribute('xyz'));
            %             end
            
            limit = xml_joint.getElementsByTagName('limit').item(0);
            joints(index).Limit = struct('effort',0,...
                'lower',0,...
                'upper',0,...
                'velocity',0);
            if ~isempty(limit)
                joints(index).Limit.effort = str2double(limit.getAttribute('effort'));
                joints(index).Limit.lower = str2double(limit.getAttribute('lower'));
                joints(index).Limit.upper = str2double(limit.getAttribute('upper'));
                joints(index).Limit.velocity = str2double(limit.getAttribute('velocity'));
            else
                joints(index).Limit.effort = 0;
                joints(index).Limit.lower = 0;
                joints(index).Limit.upper = 0;
                joints(index).Limit.velocity = 0;
            end
            
            joints(index).Actuator = struct();
            
            index = index + 1;
        end
        
    end
    
    joint_names = {joints.Name};
    % transmissions
    xml_trans = xml_robot.getElementsByTagName('transmission');
    
    num_trans = xml_trans.getLength();
    
    if num_trans~=0
        transmissions = struct();
        index = 1;
        for i=0:num_trans-1
            xml_tran = xml_trans.item(i);
            
            if xml_tran.hasChildNodes
                transmissions(index).Name = char(xml_tran.getAttribute('name'));
                if xml_tran.hasAttribute('type')
                    transmissions(index).Type = char(xml_tran.getAttribute('type'));
                elseif ~isempty(xml_tran.getElementsByTagName('type').item(0))
                    trans_type = xml_tran.getElementsByTagName('type').item(0);
                    transmissions(index).Type = char(trans_type.getNodeType);
                end
                
                trans_joint = xml_tran.getElementsByTagName('joint').item(0);
                transmissions(index).Joint = char(trans_joint.getAttribute('name'));
                joint_name = char(trans_joint.getAttribute('name'));
                joint_idx = str_index(joint_name, joint_names);
                
                
                trans_act = xml_tran.getElementsByTagName('actuator').item(0);
                if ~isempty(trans_act)
                    transmissions(index).Actuator = char(trans_act.getAttribute('name'));
                    
                    trans_ratio = xml_tran.getElementsByTagName('mechanicalReduction').item(0);
                    if ~isempty(trans_ratio)
                        transmissions(index).MechanicalReduction = str2num(trans_ratio.getFirstChild.getData);
                    else
                        transmissions(index).MechanicalReduction = 1;
                    end
                    joints(joint_idx).Actuator.GearRatio =  transmissions(index).MechanicalReduction;
                    % Ross - 6/2/2017
                    % Added support for urdf specified motorInertia
                    % URDF does not have a standard tag for motor inertia, so this will
                    % need to change if URDF adopts a standard later
                    trans_inertia = xml_tran.getElementsByTagName('motorInertia').item(0);
                    if ~isempty(trans_inertia)
                        transmissions(index).Inertia = round(str2num(trans_inertia.getFirstChild.getData),round_number);
                    else
                        transmissions(index).Inertia = 0;
                    end
                    joints(joint_idx).Actuator.RotorInertia =  transmissions(index).Inertia;
                end
                
                index = index+1;
            end
            
        end
    else
        transmissions = [];
    end
    
    
    
    

end

