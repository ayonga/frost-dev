function [name, links, joints, transmissions] = ros_load_urdf(urdf_file)
    % This function parse the ROS URDF file
    %
    % @note At this moment, this parser only support the 'link' and 'joint'
    % elements in the URDF file. More options are coming soon ...
    %
    % Return values:
    % name: the name of the robot model @type char
    % links: an array of rigid links structure @type structure
    % joints an array of rigid joints structure @type structure
    
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
            
            links(index).name = char(xml_link.getAttribute('name'));
            inertial = xml_link.getElementsByTagName('inertial').item(0);
            origin = inertial.getElementsByTagName('origin').item(0);
            mass   = inertial.getElementsByTagName('mass').item(0);
            inertia   = inertial.getElementsByTagName('inertia').item(0);
            
            
            ixx = str2double(inertia.getAttribute('ixx'));
            ixy = str2double(inertia.getAttribute('ixy'));
            ixz = str2double(inertia.getAttribute('ixz'));
            iyy = str2double(inertia.getAttribute('iyy'));
            iyz = str2double(inertia.getAttribute('iyz'));
            izz = str2double(inertia.getAttribute('izz'));
            
            links(index).mass = str2double(mass.getAttribute('value'));
            links(index).origin.xyz = str2num(origin.getAttribute('xyz')); %#ok<*ST2NM>
            rpy = str2num(origin.getAttribute('rpy'));
            if isempty(rpy)
                links(index).origin.rpy = zeros(1,3);
            else
                links(index).origin.rpy = rpy;
            end
            links(index).inertia = [ixx,ixy,ixz; ixy,iyy,iyz; ixz, iyz, izz];
            
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
            joints(index).name = char(xml_joint.getAttribute('name'));
            joints(index).type = char(xml_joint.getAttribute('type'));
            
            
            origin = xml_joint.getElementsByTagName('origin').item(0);
            axis = xml_joint.getElementsByTagName('axis').item(0);
            parent = xml_joint.getElementsByTagName('parent').item(0);
            child = xml_joint.getElementsByTagName('child').item(0);
            
            
            joints(index).origin.xyz = str2num(origin.getAttribute('xyz'));
            rpy = str2num(origin.getAttribute('rpy'));
            if isempty(rpy)
                joints(index).origin.rpy = zeros(1,3);
            else
                joints(index).origin.rpy = rpy;
            end
            joints(index).axis = str2num(axis.getAttribute('xyz'));
            joints(index).parent = char(parent.getAttribute('link'));
            joints(index).child  = char(child.getAttribute('link'));
            
            limit = xml_joint.getElementsByTagName('limit').item(0);
            joints(index).limit = struct();
            if ~isempty(limit)
                joints(index).limit.effort = str2double(limit.getAttribute('effort'));
                joints(index).limit.lower = str2double(limit.getAttribute('lower'));
                joints(index).limit.upper = str2double(limit.getAttribute('upper'));
                joints(index).limit.velocity = str2double(limit.getAttribute('velocity'));
            else
                joints(index).limit.effort = 0;
                joints(index).limit.lower = 0;
                joints(index).limit.upper = 0;
                joints(index).limit.velocity = 0;
            end
            index = index + 1;
        end
        
    end
    
    
    % transmissions
    xml_trans = xml_robot.getElementsByTagName('transmission');
    
    num_trans = xml_trans.getLength();
    
    if num_trans~=0
        transmissions = struct();
        index = 1;
        for i=0:num_trans-1
            xml_tran = xml_trans.item(i);
            
            if xml_tran.hasChildNodes
                transmissions(index).name = char(xml_tran.getAttribute('name'));
                if xml_tran.hasAttribute('type')
                    transmissions(index).type = char(xml_tran.getAttribute('type'));
                elseif ~isempty(xml_tran.getElementsByTagName('type').item(0))
                    trans_type = xml_tran.getElementsByTagName('type').item(0);
                    transmissions(index).type = char(trans_type.getNodeType);
                end
                
                trans_joint = xml_tran.getElementsByTagName('joint').item(0);
                transmissions(index).joint = char(trans_joint.getAttribute('name'));
                trans_act = xml_tran.getElementsByTagName('actuator').item(0);
                if ~isempty(trans_act)
                    transmissions(index).actuator = char(trans_act.getAttribute('name'));
                end
                
                trans_ratio = xml_tran.getElementsByTagName('mechanicalReduction').item(0);
                transmissions(index).mechanicalReduction = double(trans_ratio.getNodeType);
                index = index+1;
            end
            
        end
    else
        transmissions = [];
    end
    
    
    
    

end

