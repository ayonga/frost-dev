classdef NlpCost < NlpFcn
    % This class provides a data structure for a cost function based on the
    % NlpFcn class.
    %
    % The dimension of the cost function is always 1.
    %
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    methods
        function obj = NlpCost(name, varargin)
            % The class constructor function
            %
            % @note the dimension should be always '1'.
            
            obj = obj@NlpFcn(name, 1, varargin{:});
            
        end
        
    end
    
end