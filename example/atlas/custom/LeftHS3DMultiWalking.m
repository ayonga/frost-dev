classdef LeftHS3DMultiWalking < VirtualConstrDomain
    % Left HS (Heel-Strike) Domain 
    %
    % Contact: Left Toe (line) + Right Heel (line)
    
    properties
    end
    
    methods
        function obj = LeftHS3DMultiWalking(model)
            % construct the left toe-strike domain of the ATLAS
            % multi-contact walking
            %
            % Parameters:
            % model: the left body model of ATLAS robot
            
            obj = obj@VirtualConstrDomain('LeftHS3DMultiWalking');
            
            
            % Specifiy contact points (change to proper contact type)
            left_toe = model.Contacts.LeftToe;
            left_toe.ContactType = 'LineContactWithFriction';
            left_toe.TangentAxis = 'y';
            left_toe.Geometry = {left_toe.Geometry{1,:}};
            
            right_heel = model.Contacts.RightHeel;
            right_heel.ContactType = 'LineContactWithFriction';
            right_heel.TangentAxis = 'y';            
            right_heel.Geometry = {right_heel.Geometry{1,:}};
            
            obj = addContact(obj,{left_toe,right_heel});
            
            
            % Add fixed joitns as holonomic constraints
            if ~isempty(model.FixedDofs)
                obj = addHolonomicConstraint(obj, model.FixedDofs);
            end
            
            % Add additional unilateral constraints
            % right heel height
            obj = addUnilateralConstraint(obj, model.KinObjects.LeftHeelPosZ);
            obj = addUnilateralConstraint(obj, model.KinObjects.RightToePosZ);
            % Specify actuated joints
            actuated_joints = {
                'l_leg_akx'
                'l_leg_aky'
                'l_leg_kny'
                'l_leg_hpx'
                'l_leg_hpy'
                'l_leg_hpz'
                'r_leg_aky'
                'r_leg_kny'};
            obj = setAcutation(obj, model, actuated_joints);
            
            % virtual constraints
            obj = setPhaseVariable(obj, 'StateBased', model.KinObjects.LeftToeTau);
            obj = setVelocityOutput(obj, model.KinObjects.LeftToeDeltaPhip, 'Constant');
            obj = addPositionOutput(obj, ...
                {model.KinObjects.LeftAnklePitch,...
                model.KinObjects.LeftKneePitch,...
                model.KinObjects.LeftTorsoPitch,...
                model.KinObjects.LeftAnkleRoll,...
                model.KinObjects.LeftTorsoRoll,...
                model.KinObjects.LeftHipYaw,...
                model.KinObjects.RightAnklePitch}, ...
                'Bezier6thOrder');
        end
    end
    
end