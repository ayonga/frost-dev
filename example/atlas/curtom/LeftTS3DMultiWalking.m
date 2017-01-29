classdef LeftTS3DMultiWalking < VirtualConstrDomain
    % Left TS (Toe-Strike) Domain 
    %
    % Contact: Left Toe (planar) + Right Toe (line)
    
    properties
    end
    
    methods
        function obj = LeftTS3DMultiWalking(model)
            % construct the left toe-strike domain of the ATLAS
            % multi-contact walking
            %
            % Parameters:
            % model: the right body model of ATLAS robot
            
            obj = obj@VirtualConstrDomain('LeftTS3DMultiWalking');
            
            
            % Specifiy contact points (change to proper contact type)
            left_toe = model.Contacts.LeftToe;
            left_toe.ContactType = 'PlanarContactWithFriction';
            
            right_toe = model.Contacts.RightToe;
            right_toe.ContactType = 'LineContactWithFriction';
            right_toe.TangentAxis = 'y';
            right_toe.Geometry = {right_toe.Geometry{1,:}};
            
            obj = addContact(obj,{left_toe,right_toe});
            
            
            % Add fixed joitns as holonomic constraints
            if ~isempty(model.FixedDofs)
                obj = addHolonomicConstraint(obj, model.FixedDofs);
            end
            
            % Add additional unilateral constraints
            % left heel height
            obj = addUnilateralConstraint(obj, model.KinObjects.RightHeelPosZ);
            
            % Specify actuated joints
            actuated_joints = {
                'l_leg_akx'
                'l_leg_aky'
                'l_leg_kny'
                'l_leg_hpx'
                'l_leg_hpy'
                'l_leg_hpz'
                'r_leg_kny'};
            obj = setAcutation(obj, model, actuated_joints);
            
            % virtual constraints
            obj = setPhaseVariable(obj, 'StateBased', model.KinObjects.LeftToeTau);
            obj = setVelocityOutput(obj, model.KinObjects.LeftToeDeltaPhip, 'Constant');
            obj = addPositionOutput(obj, ...
                {model.KinObjects.LeftKneePitch,...
                model.KinObjects.LeftTorsoPitch,...
                model.KinObjects.LeftAnkleRoll,...
                model.KinObjects.LeftTorsoRoll,...
                model.KinObjects.LeftHipYaw,...
                model.KinObjects.RightKneePitch}, ...
                'Bezier6thOrder');
        end
    end
    
end