classdef RightTS3DMultiWalking < VirtualConstrDomain
    % Right TS (Toe-Strike) Domain 
    %
    % Contact: Right Toe (planar) + Left Toe (line)
    
    properties
    end
    
    methods
        function obj = RightTS3DMultiWalking(model)
            % construct the right toe-strike domain of the ATLAS
            % multi-contact walking
            %
            % Parameters:
            % model: the right body model of ATLAS robot
            
            obj = obj@VirtualConstrDomain('RightTS3DMultiWalking');
            
            
            % Specifiy contact points (change to proper contact type)
            right_toe = model.Contacts.RightToe;
            right_toe.ContactType = 'PlanarContactWithFriction';
            
            left_toe = model.Contacts.LeftToe;
            left_toe.ContactType = 'LineContactWithFriction';
            left_toe.TangentAxis = 'y';
            left_toe.Geometry = {left_toe.Geometry{1,:}};
            
            obj = addContact(obj,{right_toe,left_toe});
            
            
            % Add fixed joitns as holonomic constraints
            if ~isempty(model.FixedDofs)
                obj = addHolonomicConstraint(obj, model.FixedDofs);
            end
            
            % Add additional unilateral constraints
            % left heel height
            obj = addUnilateralConstraint(obj, model.KinObjects.LeftHeelPosZ);
            
            % Specify actuated joints
            actuated_joints = {
                'l_leg_kny'
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
                {model.KinObjects.RightKneePitch,...
                model.KinObjects.RightTorsoPitch,...
                model.KinObjects.RightAnkleRoll,...
                model.KinObjects.RightTorsoRoll,...
                model.KinObjects.RightHipYaw,...
                model.KinObjects.LeftKneePitch}, ...
                'Bezier6thOrder');
        end
    end
    
end