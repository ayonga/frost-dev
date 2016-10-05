classdef FeedbackController
    % FeedbackController defines configuration and functionalities of
    % different types of feedback controllers
    %
    % @author Ayonga Hereid @date 2016-10-04
    % 
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause 
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    properties
        
        % controller type
        %
        type
        
        % controller options and parameters
        %
        % @type struct
        options
        
        % control Lyapunov functions
        %
        % @type struct
        clfs
        
        % input parser for calcTorques
        %
        % @type inputParser
        p
    end
    
    methods
        
        function obj = FeedbackController(type)
            % The controller class constructor function
            
            obj.type = type;
            
            
            obj.p = inputParser;
            
            addRequired(obj.p,'vfc', @isnumeric);
            addRequired(obj.p,'gfc', @isnumeric);
            addOptional(obj.p,'y1',[], @isscalar);
            addRequired(obj.p,'y2', @isnumeric);
            addOptional(obj.p,'Dy1',[], @isnumeric);
            addRequired(obj.p,'Dy2', @isnumeric);
            addRequired(obj.p,'DLfy2', @isnumeric);
            addOptional(obj.p,'AeqLagrangec',[], @isnumeric);
            addOptional(obj.p,'beqLagrangec',[], @isnumeric);
            
            
            switch type
                case 'PD'
                    obj.options = struct(...
                        'Kp',10000,...
                        'Kd',1000);
                case 'PD-Feedback'
                    obj.options = struct(...
                        'Kp',10000,...
                        'Kd',1000);
                case 'IO'
                    obj.options = struct(...
                        'ep',15);
                    
                    
                case 'QP-CLF'
                    obj.options = struct(...
                        'ep',15);
            end
            
            
            
            
            
             
        end
        
    end
    
end