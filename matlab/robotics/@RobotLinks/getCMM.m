function [A_G_fun, A_G_dot_fun] = getCMM(obj, export_path)
    % 
    % 
    % Note: spatial twist = [linear; angular]
    
    n_link = numel(obj.Links);
    x = obj.States.x;
    dx = obj.States.dx;
    % compute body jacobian of all links
    fprintf('Computing symbolic expression of the body jacobian of each link: \n');
    Jb = getBodyJacobian(obj,obj.Links);
    
    % compute homogeneous transformationi from the world frame to the CoM
    % frame        
    p_com = obj.getComPosition();
    R_com = eye(3);
    T_com = [R_com, transpose(p_com); 0 0 0 1];
    
    % Note: you can replace T_com with other homogeneous transformation
    % matrix for any given frame object
    % (e.g., T_com = computeForwardKinematics(frame);)
    
    
    
    A_G_fun = cell(1,n_link);
    
    m = 100;
    fprintf('Computing symbolic expression of the centroidal momemtum matrix h_G(q): \t');
    bs = '\b';
    sp = ' ';
    msg = '%d percents completed.\n'; % carriage return included in case error interrupts loop
    msglen = length(msg)-3; % compensate for conversion character and carriage return
    fprintf(1,sp(ones(1,ceil(log10(m+1))+msglen)));
    
    for i=1:n_link
        % compute the link momentum in the body frame
        G = obj.Links(i).SpatialInertia;
        h_b= G*Jb{i};
        
        % compute homogeneous transformation matrix from each link to the
        % CoM frame
        T_w_to_link = computeForwardKinematics(obj.Links(i));
        T_link_to_w = CoordinateFrame.RigidInverse(T_w_to_link);
        T_link_to_frame = T_link_to_w*T_com;  
        
        % compute adjoint transformation matrix
        AdT_link_to_frame = CoordinateFrame.RigidAdjoint(T_link_to_frame);
        
        % compute the spatial momumtum of each link in the CoM frame coordinate
        A_G_i = AdT_link_to_frame*h_b;
        A_G_fun{i} = SymFunction(['cmm_L',num2str(i),'_',obj.Name],A_G_i,{x});
        
        
        k = floor(i*100/n_link);
        fprintf(1,[bs(mod(0:2*(ceil(log10(k+1))+msglen)-1,2)+1) msg],k);
    end
    
    
    A_G_dot_fun = cell(1,n_link);
%     m = 100;
%     fprintf('Computing symbolic expression of the centroidal momemtum matrix derivative dot{h}_G(q): \t');
%     bs = '\b';
%     sp = ' ';
%     msg = '%d percents completed.\n'; % carriage return included in case error interrupts loop
%     msglen = length(msg)-3; % compensate for conversion character and carriage return
%     fprintf(1,sp(ones(1,ceil(log10(m+1))+msglen)));
%        
%     for i=1:n_link
%         A_G_dot = jacobian(A_G_fun{i}*dx,x);
%         A_G_dot_fun{i} = SymFunction(['cmm_dot_L',num2str(i),'_',obj.Name],A_G_dot,{x,dx});
%         
%         k = floor(i*100/n_link);
%         fprintf(1,[bs(mod(0:2*(ceil(log10(k+1))+msglen)-1,2)+1) msg],k);
%     end

    
    if nargin > 1 && ~isempty(export_path)
        cellfun(@(x)export(x,export_path),A_G_fun,'UniformOutput',false);        
        
%         cellfun(@(x)export(x,export_path),A_G_dot_fun,'UniformOutput',false);   
    end
    
    obj.CMMat = A_G_fun;
%     obj.CMMatDot = A_G_dot_fun;
end

