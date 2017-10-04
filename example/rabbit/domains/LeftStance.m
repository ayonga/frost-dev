 % Left Stance Domain 
 %
 % Contact: Left Toe
function domain = LeftStance(model, load_path)
    % construct the right stance domain of RABBIT
    %
    % Parameters:
    % model: the right body model of ATLAS robot
    
    %% first make a copy of the robot model
    %| @note Do not directly assign with the model variable, since it is a
    %handle object.
    domain = copy(model);
    % set the name of the new copy
    domain.setName('LeftStance');
    
    % Extract state variables
    x = domain.States.x;
    dx = domain.States.dx;
    
    % add contact
    left_sole = ToContactFrame(domain.ContactPoints.LeftToe,...
        'PointContactWithFriction');
    fric_coef.mu = 0.6;
    domain = addContact(domain,left_sole,fric_coef, [], load_path);
    
    % add event
    % height of non-stance foot (right toe)
    p_nsf = getCartesianPosition(domain, domain.ContactPoints.RightToe);
    h_nsf = UnilateralConstraint(domain,p_nsf(3),'rightFootHeight','x');
    domain = addEvent(domain, h_nsf);
    
    % phase variable: time
    t = SymVariable('t',[1,1]);
    p = SymVariable('p',[2,1]);
    tau = (t-p(2))/(p(1)-p(2));
    
    % relative degree two outputs:
    y_q1R = x('q1_right');
    y_q2R = x('q2_right');
    y_q1L = x('q1_left');
    y_q2L = x('q2_left');
    
    ya_2 = [y_q1R;
            y_q2R;
            y_q1L;
            y_q2L];
    
    y2_label = {'q1_right',...
                'q2_right',...
                'q1_left',...
                'q2_left'};
    
    y2 = VirtualConstraint(domain,ya_2,'time','DesiredType','Bezier','PolyDegree',5,...
        'RelativeDegree',2,'OutputLabel',{y2_label},'PhaseType','TimeBased',...
        'PhaseVariable',tau,'PhaseParams',p,'Holonomic',true,...
        'LoadPath',load_path);
    
    domain = addVirtualConstraint(domain,y2);
    
end
    