function urdf_model = loadURDF(urdf_file)
    % This function parse the ROS URDF file
    %
    % @note At this moment, this parser only support the 'link' and 'joint'
    % elements in the URDF file. More options are coming soon ...
    %
    % Return values:
    % urdf_model: the parsed model structure
    
    
    urdf = xmlread(urdf_file);
    
    xml_robot = urdf.getElementsByTagName('robot').item(0);
    assert(~isempty(xml_robot),['The provided URDF file does not contains ',...
        'the proper robot element. Please provide a valid URDF file.']);
    
    urdf_model.name   = char(xml_robot.getAttribute('name'));
    
    
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
    joints = struct();
    num_joints = xml_joints.getLength();
    index = 1;
    for i=0:num_joints-1
        xml_joint = xml_joints.item(i);
        
        if xml_joint.hasChildNodes
            joints(index).name = char(xml_joint.getAttribute('name'));
            joints(index).type = char(xml_joint.getAttribute('type'));
            
            
            origin = xml_joint.getElementsByTagName('origin').item(0);
            axis = xml_joint.getElementsByTagName('axis').item(0);
            parent = xml_joint.getElementsByTagName('parent').item(0);
            child = xml_joint.getElementsByTagName('child').item(0);
            limit = xml_joint.getElementsByTagName('limit').item(0);
            
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
            joints(index).effort = str2double(limit.getAttribute('effort'));
            joints(index).lower = str2double(limit.getAttribute('lower'));
            joints(index).upper = str2double(limit.getAttribute('upper'));
            joints(index).velocity = str2double(limit.getAttribute('velocity'));
            
            index = index + 1;
        end
        
    end
    
    
    
    
    urdf_model.joints = joints;
    urdf_model.links  = links;
    
    
    

end

