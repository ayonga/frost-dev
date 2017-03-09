classdef Atlas < RigidBodyModel
    %ATLAS Model
    
    properties
        % All possible contact points
        %
        % @type struct
        Contacts
        
        % Fixed joints specified in URDF file as ''fixed''.
        % 
        % Fixed joints will be enforced via holonomic constraints 
        %
        % @type struct
        FixedDofs
        
        
        % All kinematic functions will be used in the formulation of
        % virtual constraints. 
        %
        % @type struct
        KinObjects
        
        
        
    end
    
    methods
        
        
        function obj = AtlasContactPoints(obj)
            % define all possible contact points
            
            % potential contact points
            contacts = struct();
            
            lt = 0.1728;
            lh = 0.082;
            wf = 0.1524;
            hf = -0.07645;
            
            % friction coefficient
            mu = 0.5;
            
            %% left sole (a point on the foot plane below the ankle)
            contacts.LeftSole = KinematicContact('Name','LeftSole');
            contacts.LeftSole.ParentLink = 'l_foot';
            contacts.LeftSole.Offset = [0.0, 0, hf];
            contacts.LeftSole.NormalAxis = 'z';
            contacts.LeftSole.ContactType = 'PlanarContactWithFriction';
            contacts.LeftSole.ModelType = obj.Type;
            contacts.LeftSole.Mu = mu;
            contacts.LeftSole.Geometry = {'x',[wf/2,wf/2];
                'y',[lt,lh]};
            %% right sole (a point on the foot plane below the ankle)
            contacts.RightSole = KinematicContact('Name','RightSole');
            contacts.RightSole.ParentLink = 'r_foot';
            contacts.RightSole.Offset = [0.0, 0, hf];
            contacts.RightSole.NormalAxis = 'z';
            contacts.RightSole.ContactType = 'PlanarContactWithFriction';
            contacts.RightSole.ModelType = obj.Type;
            contacts.RightSole.Mu = 0.5;
            contacts.RightSole.Geometry = {'x',[wf/2,wf/2];
                'y',[lt,lh]};
            %% left toe
            contacts.LeftToe = KinematicContact('Name','LeftToe');
            contacts.LeftToe.ParentLink = 'l_foot';
            contacts.LeftToe.Offset = [lt, 0, hf];
            contacts.LeftToe.NormalAxis = 'z';
            contacts.LeftToe.ContactType = 'PlanarContactWithFriction';
            contacts.LeftToe.ModelType = obj.Type;
            contacts.LeftToe.Mu = mu;
            contacts.LeftToe.Geometry = {'x',[wf/2,wf/2];
                'y',[0,lt+lh]};
            %% right toe
            contacts.RightToe = KinematicContact('Name','RightToe');
            contacts.RightToe.ParentLink = 'r_foot';
            contacts.RightToe.Offset = [lt, 0, hf];
            contacts.RightToe.NormalAxis = 'z';
            contacts.RightToe.ContactType = 'PlanarContactWithFriction';
            contacts.RightToe.ModelType = obj.Type;
            contacts.RightToe.Mu = 0.5;
            contacts.RightToe.Geometry = {'x',[wf/2,wf/2];
                'y',[0,lt+lh]};
            %% left heel
            contacts.LeftHeel = KinematicContact('Name','LeftHeel');
            contacts.LeftHeel.ParentLink = 'l_foot';
            contacts.LeftHeel.Offset = [-lh, 0, hf];
            contacts.LeftHeel.NormalAxis = 'z';
            contacts.LeftHeel.ContactType = 'PlanarContactWithFriction';
            contacts.LeftHeel.ModelType = obj.Type;
            contacts.LeftHeel.Mu = mu;
            contacts.LeftHeel.Geometry = {'x',[wf/2,wf/2];
                'y',[lt+lh,0]};
            %% right heel
            contacts.RightHeel = KinematicContact('Name','RightHeel');
            contacts.RightHeel.ParentLink = 'r_foot';
            contacts.RightHeel.Offset = [-lh, 0, hf];
            contacts.RightHeel.NormalAxis = 'z';
            contacts.RightHeel.ContactType = 'PlanarContactWithFriction';
            contacts.RightHeel.ModelType = obj.Type;
            contacts.RightHeel.Mu = 0.5;
            contacts.RightHeel.Geometry = {'x',[wf/2,wf/2];
                'y',[lt+lh, 0]};
            
            %% left sole (a point on the foot plane below the ankle)
            contacts.LeftSoleInside = KinematicContact('Name','LeftSoleInside');
            contacts.LeftSoleInside.ParentLink = 'l_foot';
            contacts.LeftSoleInside.Offset = [0.0, -wf/2, hf];
            contacts.LeftSoleInside.NormalAxis = 'z';
            contacts.LeftSoleInside.ContactType = 'PlanarContactWithFriction';
            contacts.LeftSoleInside.ModelType = obj.Type;
            contacts.LeftSoleInside.Mu = mu;
            contacts.LeftSoleInside.Geometry = {'x',[0,wf];
                'y',[lt,lh]};
            %% right sole (a point on the foot plane below the ankle)
            contacts.RightSoleInside = KinematicContact('Name','RightSoleInside');
            contacts.RightSoleInside.ParentLink = 'r_foot';
            contacts.RightSoleInside.Offset = [0.0, wf/2, hf];
            contacts.RightSoleInside.NormalAxis = 'z';
            contacts.RightSoleInside.ContactType = 'PlanarContactWithFriction';
            contacts.RightSoleInside.ModelType = obj.Type;
            contacts.RightSoleInside.Mu = 0.5;
            contacts.RightSoleInside.Geometry = {'x',[wf,0];
                'y',[lt,lh]};
            %% left toe
            contacts.LeftToeInside = KinematicContact('Name','LeftToeInside');
            contacts.LeftToeInside.ParentLink = 'l_foot';
            contacts.LeftToeInside.Offset = [lt, -wf/2, hf];
            contacts.LeftToeInside.NormalAxis = 'z';
            contacts.LeftToeInside.ContactType = 'PlanarContactWithFriction';
            contacts.LeftToeInside.ModelType = obj.Type;
            contacts.LeftToeInside.Mu = mu;
            contacts.LeftToeInside.Geometry = {'x',[0,wf];
                'y',[0,lt+lh]};
            %% right toe
            contacts.RightToeInside = KinematicContact('Name','RightToeInside');
            contacts.RightToeInside.ParentLink = 'r_foot';
            contacts.RightToeInside.Offset = [lt, wf/2, hf];
            contacts.RightToeInside.NormalAxis = 'z';
            contacts.RightToeInside.ContactType = 'PlanarContactWithFriction';
            contacts.RightToeInside.ModelType = obj.Type;
            contacts.RightToeInside.Mu = 0.5;
            contacts.RightToeInside.Geometry = {'x',[wf,0];
                'y',[0,lt+lh]};
            %% left heel
            contacts.LeftHeelInside = KinematicContact('Name','LeftHeelInside');
            contacts.LeftHeelInside.ParentLink = 'l_foot';
            contacts.LeftHeelInside.Offset = [-lh, -wf/2, hf];
            contacts.LeftHeelInside.NormalAxis = 'z';
            contacts.LeftHeelInside.ContactType = 'PlanarContactWithFriction';
            contacts.LeftHeelInside.ModelType = obj.Type;
            contacts.LeftHeelInside.Mu = mu;
            contacts.LeftHeelInside.Geometry = {'x',[0,wf];
                'y',[lt+lh,0]};
            %% right heel
            contacts.RightHeelInside = KinematicContact('Name','RightHeelInside');
            contacts.RightHeelInside.ParentLink = 'r_foot';
            contacts.RightHeelInside.Offset = [-lh, wf/2, hf];
            contacts.RightHeelInside.NormalAxis = 'z';
            contacts.RightHeelInside.ContactType = 'PlanarContactWithFriction';
            contacts.RightHeelInside.ModelType = obj.Type;
            contacts.RightHeelInside.Mu = 0.5;
            contacts.RightHeelInside.Geometry = {'x',[wf,0];
                'y',[lt+lh, 0]};
            
            
            %% left sole (a point on the foot plane below the ankle)
            contacts.LeftSoleOutside = KinematicContact('Name','LeftSoleOutside');
            contacts.LeftSoleOutside.ParentLink = 'l_foot';
            contacts.LeftSoleOutside.Offset = [0.0, wf/2, hf];
            contacts.LeftSoleOutside.NormalAxis = 'z';
            contacts.LeftSoleOutside.ContactType = 'PlanarContactWithFriction';
            contacts.LeftSoleOutside.ModelType = obj.Type;
            contacts.LeftSoleOutside.Mu = mu;
            contacts.LeftSoleOutside.Geometry = {'x',[wf,0];
                'y',[lt,lh]};
            %% right sole (a point on the foot plane below the ankle)
            contacts.RightSoleOutside = KinematicContact('Name','RightSoleOutside');
            contacts.RightSoleOutside.ParentLink = 'r_foot';
            contacts.RightSoleOutside.Offset = [0.0, -wf/2, hf];
            contacts.RightSoleOutside.NormalAxis = 'z';
            contacts.RightSoleOutside.ContactType = 'PlanarContactWithFriction';
            contacts.RightSoleOutside.ModelType = obj.Type;
            contacts.RightSoleOutside.Mu = 0.5;
            contacts.RightSoleOutside.Geometry = {'x',[0,wf];
                'y',[lt,lh]};
            %% left toe
            contacts.LeftToeOutside = KinematicContact('Name','LeftToeOutside');
            contacts.LeftToeOutside.ParentLink = 'l_foot';
            contacts.LeftToeOutside.Offset = [lt, wf/2, hf];
            contacts.LeftToeOutside.NormalAxis = 'z';
            contacts.LeftToeOutside.ContactType = 'PlanarContactWithFriction';
            contacts.LeftToeOutside.ModelType = obj.Type;
            contacts.LeftToeOutside.Mu = mu;
            contacts.LeftToeOutside.Geometry = {'x',[wf,0];
                'y',[0,lt+lh]};
            %% right toe
            contacts.RightToeOutside = KinematicContact('Name','RightToeOutside');
            contacts.RightToeOutside.ParentLink = 'r_foot';
            contacts.RightToeOutside.Offset = [lt, -wf/2, hf];
            contacts.RightToeOutside.NormalAxis = 'z';
            contacts.RightToeOutside.ContactType = 'PlanarContactWithFriction';
            contacts.RightToeOutside.ModelType = obj.Type;
            contacts.RightToeOutside.Mu = 0.5;
            contacts.RightToeOutside.Geometry = {'x',[0,wf];
                'y',[0,lt+lh]};
            %% left heel
            contacts.LeftHeelOutside = KinematicContact('Name','LeftHeelOutside');
            contacts.LeftHeelOutside.ParentLink = 'l_foot';
            contacts.LeftHeelOutside.Offset = [-lh, wf/2, hf];
            contacts.LeftHeelOutside.NormalAxis = 'z';
            contacts.LeftHeelOutside.ContactType = 'PlanarContactWithFriction';
            contacts.LeftHeelOutside.ModelType = obj.Type;
            contacts.LeftHeelOutside.Mu = mu;
            contacts.LeftHeelOutside.Geometry = {'x',[wf,0];
                'y',[lt+lh,0]};
            %% right heel
            contacts.RightHeelOutside = KinematicContact('Name','RightHeelOutside');
            contacts.RightHeelOutside.ParentLink = 'r_foot';
            contacts.RightHeelOutside.Offset = [-lh, -wf/2, hf];
            contacts.RightHeelOutside.NormalAxis = 'z';
            contacts.RightHeelOutside.ContactType = 'PlanarContactWithFriction';
            contacts.RightHeelOutside.ModelType = obj.Type;
            contacts.RightHeelOutside.Mu = 0.5;
            contacts.RightHeelOutside.Geometry = {'x',[0,wf];
                'y',[lt+lh, 0]};
            
            
            
            
            
            
            obj.Contacts = contacts;
        end
        
        
        function obj = PositionKinemticFunction(obj)
            
            if isempty(obj.KinObjects)
                obj.KinObjects = struct;
            end
            
            % create 3 kinematic position (x,y,z) objects for each contact
            % point
            contacts = obj.Contacts;
            points = fields(contacts);
            
            for i=1:length(points)
                contact_point = points{i};
                
                obj.KinObjects.([contact_point,'PosX']) = ...
                    KinematicPosition('Name', [contacts.(contact_point).Name,'PosX'],...
                    'ParentLink',contacts.(contact_point).ParentLink,...
                    'Axis','x',...
                    'Offset',contacts.(contact_point).Offset);
                
                obj.KinObjects.([contact_point,'PosY']) = ...
                    KinematicPosition('Name', [contacts.(contact_point).Name,'PosY'],...
                    'ParentLink',contacts.(contact_point).ParentLink,...
                    'Axis','y',...
                    'Offset',contacts.(contact_point).Offset);
                
                obj.KinObjects.([contact_point,'PosZ']) = ...
                    KinematicPosition('Name', [contacts.(contact_point).Name,'PosZ'],...
                    'ParentLink',contacts.(contact_point).ParentLink,...
                    'Axis','z',...
                    'Offset',contacts.(contact_point).Offset);
            end
            %% Other Positions
            % Hip position 
            obj.KinObjects.LeftHipPosX = KinematicPosition('Name', 'LeftHipPosX',...
                'ParentLink','l_uleg',...
                'Axis','x',...
                'Offset',[0,0,0]);
            obj.KinObjects.RightHipPosX = KinematicPosition('Name', 'RightHipPosX',...
                'ParentLink','r_uleg',...
                'Axis','x',...
                'Offset',[0,0,0]);
            
            obj.KinObjects.LeftHipPosY = KinematicPosition('Name', 'LeftHipPosY',...
                'ParentLink','l_uleg',...
                'Axis','y',...
                'Offset',[0,0,0]);
            obj.KinObjects.RightHipPosY = KinematicPosition('Name', 'RightHipPosY',...
                'ParentLink','r_uleg',...
                'Axis','y',...
                'Offset',[0,0,0]);
            
            obj.KinObjects.LeftHipPosZ = KinematicPosition('Name', 'LeftHipPosZ',...
                'ParentLink','l_uleg',...
                'Axis','z',...
                'Offset',[0,0,0]);
            obj.KinObjects.RightHipPosZ = KinematicPosition('Name', 'RightHipPosZ',...
                'ParentLink','r_uleg',...
                'Axis','z',...
                'Offset',[0,0,0]);
            
            % Ankle positions
            obj.KinObjects.LeftAnklePosX = KinematicPosition('Name', 'LeftAnklePosX',...
                'ParentLink','l_talus',...
                'Axis','x',...
                'Offset',[0,0,0]);
            obj.KinObjects.RightAnklePosX = KinematicPosition('Name', 'RightAnklePosX',...
                'ParentLink','r_talus',...
                'Axis','x',...
                'Offset',[0,0,0]);
            
            obj.KinObjects.LeftAnklePosY = KinematicPosition('Name', 'LeftAnklePosY',...
                'ParentLink','l_talus',...
                'Axis','y',...
                'Offset',[0,0,0]);
            obj.KinObjects.RightAnklePosY = KinematicPosition('Name', 'RightAnklePosY',...
                'ParentLink','r_talus',...
                'Axis','y',...
                'Offset',[0,0,0]);
            
            obj.KinObjects.LeftAnklePosZ = KinematicPosition('Name', 'LeftAnklePosZ',...
                'ParentLink','l_talus',...
                'Axis','z',...
                'Offset',[0,0,0]);
            obj.KinObjects.RightAnklePosZ = KinematicPosition('Name', 'RightAnklePosZ',...
                'ParentLink','r_talus',...
                'Axis','z',...
                'Offset',[0,0,0]);
            % 
            % Knee position 
            obj.KinObjects.LeftKneePosX = KinematicPosition('Name', 'LeftKneePosX',...
                'ParentLink','l_lleg',...
                'Axis','x',...
                'Offset',[0,0,0]);
            obj.KinObjects.RightKneePosX = KinematicPosition('Name', 'RightKneePosX',...
                'ParentLink','r_lleg',...
                'Axis','x',...
                'Offset',[0,0,0]);
            
            obj.KinObjects.LeftKneePosY = KinematicPosition('Name', 'LeftKneePosY',...
                'ParentLink','l_lleg',...
                'Axis','y',...
                'Offset',[0,0,0]);
            obj.KinObjects.RightKneePosY = KinematicPosition('Name', 'RightKneePosY',...
                'ParentLink','r_lleg',...
                'Axis','y',...
                'Offset',[0,0,0]);
            
            obj.KinObjects.LeftKneePosZ = KinematicPosition('Name', 'LeftKneePosZ',...
                'ParentLink','l_lleg',...
                'Axis','z',...
                'Offset',[0,0,0]);
            obj.KinObjects.RightKneePosZ = KinematicPosition('Name', 'RightKneePosZ',...
                'ParentLink','r_lleg',...
                'Axis','z',...
                'Offset',[0,0,0]);
            
            % Torso
            obj.KinObjects.TorsoPosZ = KinematicPosition('Name', 'TorsoPosZ',...
                'ParentLink','pelvis',...
                'Axis','z',...
                'Offset',[0,0,0.4]);
            obj.KinObjects.TorsoPosY = KinematicPosition('Name', 'TorsoPosY',...
                'ParentLink','pelvis',...
                'Axis','y',...
                'Offset',[0,0,0.4]);
            obj.KinObjects.TorsoPosX = KinematicPosition('Name', 'TorsoPosX',...
                'ParentLink','pelvis',...
                'Axis','x',...
                'Offset',[0,0,0.4]);
            
            obj.KinObjects.PelvisPosZ = KinematicPosition('Name', 'PelvisPosz',...
                'ParentLink','pelvis',...
                'Axis','z',...
                'Offset',[0,0,0]);
            obj.KinObjects.PelvisPosY = KinematicPosition('Name', 'PelvisPosY',...
                'ParentLink','pelvis',...
                'Axis','y',...
                'Offset',[0,0,0]);
            obj.KinObjects.PelvisPosX = KinematicPosition('Name', 'PelvisPosX',...
                'ParentLink','pelvis',...
                'Axis','x',...
                'Offset',[0,0,0]);
        end
        
        function obj = JointKinemticFunction(obj)
            % construct potentially useful kinematic object of the robot
            
            if isempty(obj.KinObjects)
                obj.KinObjects = struct;
            end
            
            %% DoFs
            % Make joints as a KinematicDof object
            obj.KinObjects.LeftAnkleRoll = KinematicDof('Name','LeftAnkleRoll',...
                'DofName','l_leg_akx');
            obj.KinObjects.RightAnkleRoll = KinematicDof('Name','RightAnkleRoll',...
                'DofName','r_leg_akx');
            
            obj.KinObjects.LeftHipRoll = KinematicDof('Name','LeftHipRoll',...
                'DofName','l_leg_hpx');
            obj.KinObjects.RightHipRoll = KinematicDof('Name','RightHipRoll',...
                'DofName','r_leg_hpx');
            
            obj.KinObjects.LeftAnklePitch = KinematicDof('Name','LeftAnklePitch',...
                'DofName','l_leg_aky');
            obj.KinObjects.RightAnklePitch = KinematicDof('Name','RightAnklePitch',...
                'DofName','r_leg_aky');
            
            obj.KinObjects.LeftKneePitch = KinematicDof('Name','LeftKneePitch',...
                'DofName','l_leg_kny');
            obj.KinObjects.RightKneePitch = KinematicDof('Name','RightKneePitch',...
                'DofName','r_leg_kny');
            
            obj.KinObjects.LeftHipPitch = KinematicDof('Name','LeftHipPitch',...
                'DofName','l_leg_hpy');
            obj.KinObjects.RightHipPitch = KinematicDof('Name','RightHipPitch',...
                'DofName','r_leg_hpy');
            
            obj.KinObjects.LeftHipYaw = KinematicDof('Name','LeftHipYaw',...
                'DofName','l_leg_hpz');
            obj.KinObjects.RightHipYaw = KinematicDof('Name','RightHipYaw',...
                'DofName','r_leg_hpz');
            
            
            
        end
        
        function obj = CompositeKinematicFunction(obj)
            % Kinematic functions composed of multiple kinematic functions
            
            if isempty(obj.KinObjects)
                obj.KinObjects = struct;
            end
            
            %% velocity outputs
            obj.KinObjects.LeftDeltaPhip = KinematicExpr('Name', 'LeftDeltaPhip',...
                'Linearize', true,...
                'Dependents', {{obj.KinObjects.LeftHipPosX, obj.KinObjects.LeftSolePosX}},...
                'Expression', 'LeftHipPosX - LeftSolePosX');
            obj.KinObjects.RightDeltaPhip = KinematicExpr('Name', 'RightDeltaPhip',...
                'Linearize', true,...
                'Dependents', {{obj.KinObjects.RightHipPosX, obj.KinObjects.RightSolePosX}},...
                'Expression', 'RightHipPosX - RightSolePosX');
            
            obj.KinObjects.LeftToeDeltaPhip = KinematicExpr('Name', 'LeftToeDeltaPhip',...
                'Linearize', true,...
                'Dependents', {{obj.KinObjects.LeftHipPosX, obj.KinObjects.LeftToePosX}},...
                'Expression', 'LeftHipPosX - LeftToePosX');
            obj.KinObjects.RightToeDeltaPhip = KinematicExpr('Name', 'RightToeDeltaPhip',...
                'Linearize', true,...
                'Dependents', {{obj.KinObjects.RightHipPosX, obj.KinObjects.RightToePosX}},...
                'Expression', 'RightHipPosX - RightToePosX');
            
            
            %% phase variables
            obj.KinObjects.RightTau = KinematicExpr('Name', 'RightTau');
            obj.KinObjects.RightTau.Dependents = {obj.KinObjects.RightDeltaPhip};
            obj.KinObjects.RightTau.Expression = '(RightDeltaPhip - p[2])/(p[1] - p[2])';
            obj.KinObjects.RightTau.Parameters = struct('Name','p','Dimension',2);
            
            obj.KinObjects.LeftTau = KinematicExpr('Name', 'LeftTau');
            obj.KinObjects.LeftTau.Dependents = {obj.KinObjects.LeftDeltaPhip};
            obj.KinObjects.LeftTau.Expression = '(LeftDeltaPhip - p[2])/(p[1] - p[2])';
            obj.KinObjects.LeftTau.Parameters = struct('Name','p','Dimension',2);
            
            obj.KinObjects.RightToeTau = KinematicExpr('Name', 'RightToeTau');
            obj.KinObjects.RightToeTau.Dependents = {obj.KinObjects.RightToeDeltaPhip};
            obj.KinObjects.RightToeTau.Expression = '(RightToeDeltaPhip - p[2])/(p[1] - p[2])';
            obj.KinObjects.RightToeTau.Parameters = struct('Name','p','Dimension',2);
            
            obj.KinObjects.LeftToeTau = KinematicExpr('Name', 'LeftToeTau');
            obj.KinObjects.LeftToeTau.Dependents = {obj.KinObjects.LeftToeDeltaPhip};
            obj.KinObjects.LeftToeTau.Expression = '(LeftToeDeltaPhip - p[2])/(p[1] - p[2])';
            obj.KinObjects.LeftToeTau.Parameters = struct('Name','p','Dimension',2);
            
            %% position outputs
            
            
            obj.KinObjects.LeftTorsoPitch = KinematicExpr('Name','LeftTorsoPitch',...
                'Dependents',{{obj.KinObjects.LeftAnklePitch, obj.KinObjects.LeftKneePitch, obj.KinObjects.LeftHipPitch}},...
                'Expression','- LeftAnklePitch - LeftKneePitch - LeftHipPitch');
            obj.KinObjects.RightTorsoPitch = KinematicExpr('Name','RightTorsoPitch',...
                'Dependents',{{obj.KinObjects.RightAnklePitch, obj.KinObjects.RightKneePitch, obj.KinObjects.RightHipPitch}},...
                'Expression','- RightAnklePitch - RightKneePitch - RightHipPitch');
            
            obj.KinObjects.LeftTorsoRoll = KinematicExpr('Name','LeftTorsoRoll',...
                'Dependents',{{obj.KinObjects.LeftAnkleRoll, obj.KinObjects.LeftHipRoll}},...
                'Expression','- LeftAnkleRoll - LeftHipRoll');
            obj.KinObjects.RightTorsoRoll = KinematicExpr('Name','RightTorsoRoll',...
                'Dependents',{{obj.KinObjects.RightAnkleRoll, obj.KinObjects.RightHipRoll}},...
                'Expression','- RightAnkleRoll - RightHipRoll');
            
            
   
            obj.KinObjects.RightLinNSlope = KinematicExpr('Name', 'RightLinNSlope',...
                'Linearize', true,...
                'Dependents',{{obj.KinObjects.RightAnklePosX, obj.KinObjects.RightHipPosX, ...
                obj.KinObjects.RightAnklePosZ, obj.KinObjects.RightHipPosZ}},...
                'Expression','(RightAnklePosX - RightHipPosX) / (RightAnklePosZ - RightHipPosZ)');
            
            obj.KinObjects.LeftLinNSlope = KinematicExpr('Name', 'LeftLinNSlope',...
                'Linearize', true,...
                'Dependents',{{obj.KinObjects.LeftAnklePosX, obj.KinObjects.LeftHipPosX, ...
                obj.KinObjects.LeftAnklePosZ, obj.KinObjects.LeftHipPosZ}},...
                'Expression','(LeftAnklePosX - LeftHipPosX) / (LeftAnklePosZ - LeftHipPosZ)');
    
            obj.KinObjects.RightLegRoll = KinematicExpr('Name','RightLegRoll',...
                'Dependents',{{obj.KinObjects.LeftHipRoll, obj.KinObjects.RightHipRoll}},...
                'Expression','LeftHipRoll - RightHipRoll');
            obj.KinObjects.LeftLegRoll = KinematicExpr('Name','LeftLegRoll',...
                'Dependents',{{obj.KinObjects.RightHipRoll, obj.KinObjects.LeftHipRoll}},...
                'Expression','RightHipRoll - LeftHipRoll');
            
            
            %% Foot orientations
            obj.KinObjects.RightFootRoll = KinematicExpr('Name','RightFootRoll',...
                'Dependents',{{obj.KinObjects.RightSoleInsidePosZ, obj.KinObjects.RightSoleOutsidePosZ}},...
                'Expression','RightSoleInsidePosZ - RightSoleOutsidePosZ');
            obj.KinObjects.RightFootPitch = KinematicExpr('Name','RightFootPitch',...
                'Dependents',{{obj.KinObjects.RightHeelPosZ, obj.KinObjects.RightToePosZ}},...
                'Expression','RightHeelPosZ - RightToePosZ');
            obj.KinObjects.RightFootYaw = KinematicExpr('Name','RightFootYaw',...
                'Dependents',{{obj.KinObjects.RightHeelPosY, obj.KinObjects.RightToePosY}},...
                'Expression','RightHeelPosY - RightToePosY');
            
            obj.KinObjects.LeftFootRoll = KinematicExpr('Name','LeftFootRoll',...
                'Dependents',{{obj.KinObjects.LeftSoleInsidePosZ, obj.KinObjects.LeftSoleOutsidePosZ}},...
                'Expression','LeftSoleInsidePosZ - LeftSoleOutsidePosZ');
            obj.KinObjects.LeftFootPitch = KinematicExpr('Name','LeftFootPitch',...
                'Dependents',{{obj.KinObjects.LeftHeelPosZ, obj.KinObjects.LeftToePosZ}},...
                'Expression','LeftHeelPosZ - LeftToePosZ');
            obj.KinObjects.LeftFootYaw = KinematicExpr('Name','LeftFootYaw',...
                'Dependents',{{obj.KinObjects.LeftHeelPosY, obj.KinObjects.LeftToePosY}},...
                'Expression','LeftHeelPosY - LeftToePosY');
        end
        
        function obj = Atlas(urdf)
            
            BaseDof = struct;
            BaseDof.type = 'floating';
            BaseDof.lower = [-0.6, -0.2, 0.7, -0.05, -0.5, -0.05];
            BaseDof.upper =  [0.3, 0.2, 0.9, 0.05, 0.5, 0.05];
            BaseDof.minVelocity =  [0.2, -0.1, -0.5, -0.5, -0.5, -0.5];
            BaseDof.maxVelocity =  [1, 0.1, 0.5, 0.5, 0.5, 0.5];
            
            
            obj = obj@RigidBodyModel(urdf,BaseDof,'spatial');
            
            obj = AtlasContactPoints(obj);
            
            fixed_joints = obj.Dof(strcmp('fixed',{obj.Dof.type}));
            obj.FixedDofs = cell(1, numel(fixed_joints));
            for i=1:numel(fixed_joints)
                obj.FixedDofs{i} = KinematicDof('Name',regexprep(fixed_joints(i).name,'_',''),...
                    'DofName',fixed_joints(i).name);                
            end
            
            
            obj = JointKinemticFunction(obj);
            
            obj = PositionKinemticFunction(obj);
            
            obj = CompositeKinematicFunction(obj);
            
            
            obj = AtlasAnimation(obj);
            
            
            
            
            
        end
        
        function obj = AtlasAnimation(obj)
            
            
            kin = obj.KinObjects;
            upper_body = KinematicGroup('Name', 'UpperBody', 'AllowDuplicate', true);
            upper_body = upper_body.addKinematic(...
                {kin.PelvisPosX,kin.PelvisPosY,kin.PelvisPosZ,...
                kin.TorsoPosX,kin.TorsoPosY,kin.TorsoPosZ});
            line_objects(1).Kin = upper_body;
            line_objects(1).Color = 'g';
            line_objects(1).Style = '-o';
            line_objects(1).LineWidth = 6;
            line_objects(1).MarkerSize = 4;
            line_objects(1).NumPoint = 2;
            
            
            left_leg = KinematicGroup('Name', 'LeftLeg', 'AllowDuplicate', true);
            left_leg = left_leg.addKinematic(...
                {kin.PelvisPosX,kin.PelvisPosY,kin.PelvisPosZ,...
                kin.LeftHipPosX,kin.LeftHipPosY,kin.LeftHipPosZ,...
                kin.LeftKneePosX,kin.LeftKneePosY,kin.LeftKneePosZ,...
                kin.LeftAnklePosX,kin.LeftAnklePosY,kin.LeftAnklePosZ,...
                kin.LeftToePosX,kin.LeftToePosY,kin.LeftToePosZ,...
                kin.LeftHeelPosX,kin.LeftHeelPosY,kin.LeftHeelPosZ,...
                kin.LeftAnklePosX,kin.LeftAnklePosY,kin.LeftAnklePosZ});
            line_objects(2).Kin = left_leg;
            line_objects(2).Color = 'r';
            line_objects(2).Style = '-o';
            line_objects(2).LineWidth = 6;
            line_objects(2).MarkerSize = 4;
            line_objects(2).NumPoint = 7;
            
            
            right_leg = KinematicGroup('Name', 'RightLeg', 'AllowDuplicate', true);
            right_leg = right_leg.addKinematic(...
                {kin.PelvisPosX,kin.PelvisPosY,kin.PelvisPosZ,...
                kin.RightHipPosX,kin.RightHipPosY,kin.RightHipPosZ,...
                kin.RightKneePosX,kin.RightKneePosY,kin.RightKneePosZ,...
                kin.RightAnklePosX,kin.RightAnklePosY,kin.RightAnklePosZ,...
                kin.RightToePosX,kin.RightToePosY,kin.RightToePosZ,...
                kin.RightHeelPosX,kin.RightHeelPosY,kin.RightHeelPosZ,...
                kin.RightAnklePosX,kin.RightAnklePosY,kin.RightAnklePosZ});
            line_objects(3).Kin = right_leg;
            line_objects(3).Color = 'b';
            line_objects(3).Style = '-o';
            line_objects(3).LineWidth = 6;
            line_objects(3).MarkerSize = 4;
            line_objects(3).NumPoint = 7;
            
            obj.LineObjects = line_objects;
        end
    end
    
end

