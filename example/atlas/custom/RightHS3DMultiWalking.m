classdef RightHS3DMultiWalking < VirtualConstrDomain
    % Right HS (Heel-Strike) Domain 
    %
    % Contact: Right Toe (line) + Left Heel (line)
    
    properties
    end
    
    methods
        function obj = RightHS3DMultiWalking(model)
            % construct the right toe-strike domain of the ATLAS
            % multi-contact walking
            %
            % Parameters:
            % model: the right body model of ATLAS robot
            
            obj = obj@VirtualConstrDomain('RightHS3DMultiWalking');
            
            
            % Specifiy contact points (change to proper contact type)
            right_toe = model.Contacts.RightToe;
            right_toe.ContactType = 'LineContactWithFriction';
            right_toe.TangentAxis = 'y';
            right_toe.Geometry = {right_toe.Geometry{1,:}};
            
            left_heel = model.Contacts.LeftHeel;
            left_heel.ContactType = 'LineContactWithFriction';
            left_heel.TangentAxis = 'y';
            left_heel.Geometry = {left_heel.Geometry{1,:}};
            
            obj = addContact(obj,{right_toe,left_heel});
            
            
            % Add fixed joitns as holonomic constraints
            if ~isempty(model.FixedDofs)
                obj = addHolonomicConstraint(obj, model.FixedDofs);
            end
            
            % Add additional unilateral constraints
            % left heel height
            obj = addUnilateralConstraint(obj, model.KinObjects.RightHeelPosZ);
            obj = addUnilateralConstraint(obj, model.KinObjects.LeftToePosZ);
            % Specify actuated joints
            actuated_joints = {
                'l_leg_kny'
                'l_leg_hpy'
                'r_leg_akx'
                'r_leg_aky'
                'r_leg_kny'
                'r_leg_hpx'
                'r_leg_hpy'
                'r_leg_hpz'};
            obj = setAcutation(obj, model, actuated_joints);
            
            % virtual constraints
            obj = setPhaseVariable(obj, 'StateBased', model.KinObjects.RightToeTau);
            obj = setVelocityOutput(obj, model.KinObjects.RightToeDeltaPhip, 'Constant');
            obj = addPositionOutput(obj, ...
                {model.KinObjects.RightAnklePitch,...
                model.KinObjects.RightKneePitch,...
                model.KinObjects.RightTorsoPitch,...
                model.KinObjects.RightAnkleRoll,...
                model.KinObjects.RightTorsoRoll,...
                model.KinObjects.RightHipYaw,...
                model.KinObjects.LeftAnklePitch}, ...
                'Bezier6thOrder');
        end
    end
    
end