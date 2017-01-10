classdef KinematicGroup < Kinematics
    % Defines a group of kinematic constraint that expressed as functions
    % of other kinematic constraints.
    % 
    %
    % @author Ayonga Hereid @date 2016-09-23
    % 
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause 
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    properties (SetAccess=protected, GetAccess=public)
        
       
        
        % The group of Kinematic constraints objects represented by an
        % array of structures
        %
        % Required fields of KinGroupTable:
        %  Name: the name of the kinematic object @type char
        %  KinObj: the kinematic object @type Kinematic
        %  Index: the indices of the kinematic object in the group 
        %  @type rowvec
        %
        % @type struct
        KinGroupTable
        
        
    end % properties
    
    
    methods
        
        function obj = KinematicGroup(varargin)
            % The constructor function
            %
            % @copydetails Kinematics::Kinematics()
            %
            % See also: Kinematics
            
            
            
            obj = obj@Kinematics(varargin{:});
            if nargin == 0
                return;
            end
            
            
            
            % initialize the fields 
            obj.KinGroupTable = struct('Name',[],'KinObj',[],'Index',[]);
            % make an empty struct
            obj.KinGroupTable(1) = [];
            
            % objStruct = struct(varargin{:});
            % if isfield(objStruct, 'KinGroupTable')
            %     obj.KinGroupTable = objStruct.KinGroupTable;
            % end
        end
        
        
        
        
        
        
        
        
        
        
        function dim = getDimension(obj)
            % Returns the dimension of the kinematic function.
            
            dim = sum(cellfun(@(x)getDimension(x),{obj.KinGroupTable.KinObj}));
        end
    end % methods
    
    %% Methods defined in separate files
    methods
        status = compile(obj, model, re_load);
        
        obj = addKinematic(obj, kin);
                
        obj = removeKinematic(obj, kin);
        
        obj = updateIndex(obj);
                
        index = getIndex(obj, kin)
    end
    
    
    methods (Access = protected)
        
        % overload the default compile function
        % function cmd = getKinMathCommand(obj)
        % end
        
        % overload the default compile function
        % function cmd = getJacMathCommand(obj)
        % end
        
        % use default function
        % function cmd = getJacDotMathCommand(obj)
        % end
        
        
    end % private methods
    
end % classdef
