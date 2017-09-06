classdef FlippyPickBurger < VirtualConstrDomain
    % Left TS (Toe-Strike) Domain 
    %
    % Contact: Left Toe (planar) + Right Toe (line)
    
    properties
    end
    
    methods
        function obj = FlippyPickBurger(model)
            % construct the movement of FLIPPY to the burger and perform 
            %        and pick
            % 
            % Parameters:
            % model: the FLIPPY robot without the burger
            
            obj = obj@VirtualConstrDomain('FlippyPickBurger');
            
            
            % Specifiy contact points (change to proper contact type)
            base = model.Contacts.Base;
%             base.ContactType = 'PlanarContactWithFriction';
%             base.TangentAxis = 'y';
            
            obj = addContact(obj,{base});
            
            
            % Add fixed joitns as holonomic constraints
            if ~isempty(model.FixedDofs)
                obj = addHolonomicConstraint(obj, model.FixedDofs);
            end
            
            % Add additional unilateral constraints
            obj = addUnilateralConstraint(obj, model.KinObjects.DeltaFinal);
%             obj.threshold = -1;
            
            % Specify actuated joints
            actuated_joints = {
                'shoulder_pan_joint'
                'shoulder_lift_joint'
                'elbow_joint'
                'wrist_2_joint'
                'wrist_1_joint'
                'wrist_3_joint'};
            obj = setAcutation(obj, model, actuated_joints);
            
            % virtual constraints
            obj = setPhaseVariable(obj, 'StateBased', model.KinObjects.Tau);
            obj = setVelocityOutput(obj, model.KinObjects.DeltaPan, 'Constant');
            obj = addPositionOutput(obj, ...
                {model.KinObjects.ShoulderPan,...
                model.KinObjects.ShoulderLift,...
                model.KinObjects.Elbow,...
                model.KinObjects.WristYaw,...
                model.KinObjects.WristPitch}, ...
                'Bezier6thOrder');
        end
    end
    
end