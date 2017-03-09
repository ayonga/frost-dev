classdef LeftTL3DMultiWalking < VirtualConstrDomain
    % Left TL (Toe-Lift) Domain 
    %
    % Contact: Left Toe (planar)
    
    properties
    end
    
    methods
        function obj = LeftTL3DMultiWalking(model)
            % construct the left toe-strike domain of the ATLAS
            % multi-contact walking
            %
            % Parameters:
            % model: the left body model of ATLAS robot
            
            obj = obj@VirtualConstrDomain('LeftTL3DMultiWalking');
            
            
            % Specifiy contact points (change to proper contact type)
            left_toe = model.Contacts.LeftToe;
            left_toe.ContactType = 'PlanarContactWithFriction';
            
            
            obj = addContact(obj,{left_toe});
            
            
            % Add fixed joitns as holonomic constraints
            if ~isempty(model.FixedDofs)
                obj = addHolonomicConstraint(obj, model.FixedDofs);
            end
            
            % Add additional unilateral constraints
            % left heel height
            obj = addUnilateralConstraint(obj, model.KinObjects.RightHeelPosZ);
            obj = addUnilateralConstraint(obj, model.KinObjects.RightToePosZ);
            % Specify actuated joints
            actuated_joints = {
                'l_leg_akx'
                'l_leg_aky'
                'l_leg_kny'
                'l_leg_hpx'
                'l_leg_hpy'
                'l_leg_hpz'
                'r_leg_akx'
                'r_leg_aky'
                'r_leg_kny'
                'r_leg_hpx'
                'r_leg_hpy'
                'r_leg_hpz'};
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
                model.KinObjects.RightKneePitch,...
                model.KinObjects.RightLinNSlope,...
                model.KinObjects.RightAnklePitch,...
                model.KinObjects.RightLegRoll,...
                model.KinObjects.RightFootRoll,...
                model.KinObjects.RightFootYaw}, ...
                'Bezier6thOrder');
        end
    end
    
end