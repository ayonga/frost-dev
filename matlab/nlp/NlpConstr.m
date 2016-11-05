classdef NlpConstr < NlpFcn
    % This class provides a data structure for a optimization constraints
    % based on the NlpFcn class. 
    %
    % This class defines a few additional properties that only belong to
    % NLP constraints.
    %
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    properties
        % The lower boundary values of the constraints
        %
        % @type colvec
        cl
        
        % The upper boundary values of the constraints
        %
        % @type colvec
        cu
        
        % The indexing information of the constraints
        %
        % @type colvec
        c_index
    end
    
    methods
    
        function obj = NlpConstr(name, dimension, cl, cu, varargin)
            % The class constructor function
            %
            % @note the dimension should be always '1'.
            
            obj = obj@NlpFcn(name, dimension, varargin{:});
            
            % constraints boundaries
            if isscalar(cl)
                obj.cl = cl*ones(obj.dims,1);
            end
            if isscalar(cu)
                obj.cu = cu*ones(obj.dims,1);
            end
            
            
            
        end
        
        function obj = setConstrIndices(obj, cIndex0)
            % It sets the indexing of the constraints in the list of
            % constraints array
            %
            % Parameters:
            %  cIndex0: the starting index of the j_index @type integer
            
            
            obj.c_index = cIndex0 + cumsum(ones(obj.dims,1));
            
            
        end
    end
end