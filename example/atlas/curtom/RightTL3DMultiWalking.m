classdef RightTL3DMultiWalking < VirtualConstrDomain
    % Right TL (Toe-Lift) Domain 
    %
    % Contact: Right Toe (planar)
    
    properties
    end
    
    methods
        function obj = RightTL3DMultiWalking(model)
            % construct the right toe-strike domain of the ATLAS
            % multi-contact walking
            %
            % Parameters:
            % model: the right body model of ATLAS robot
            
            obj = obj@VirtualConstrDomain('RightTL3DMultiWalking');
            
            
            % Specifiy contact points (change to proper contact type)
            right_toe = model.Contacts.RightToe;
            right_toe.ContactType = 'PlanarContactWithFriction';
            
            
            obj = addContact(obj,{right_toe});
            
            
            % Add fixed joitns as holonomic constraints
            if ~isempty(model.FixedDofs)
                obj = addHolonomicConstraint(obj, model.FixedDofs);
            end
            
            % Add additional unilateral constraints
            % left heel height
            obj = addUnilateralConstraint(obj, model.KinObjects.LeftHeelPosZ);
            obj = addUnilateralConstraint(obj, model.KinObjects.LeftToePosZ);
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
            obj = setPhaseVariable(obj, 'StateBased', model.KinObjects.RightToeTau);
            obj = setVelocityOutput(obj, model.KinObjects.RightToeDeltaPhip, 'Constant');
            obj = addPositionOutput(obj, ...
                {model.KinObjects.RightKneePitch,...
                model.KinObjects.RightTorsoPitch,...
                model.KinObjects.RightAnkleRoll,...
                model.KinObjects.RightTorsoRoll,...
                model.KinObjects.RightHipYaw,...
                model.KinObjects.LeftKneePitch,...
                model.KinObjects.LeftLinNSlope,...
                model.KinObjects.LeftAnklePitch,...
                model.KinObjects.LeftLegRoll,...
                model.KinObjects.LeftFootRoll,...
                model.KinObjects.LeftFootYaw}, ...
                'Bezier6thOrder');
        end
    end
    
end