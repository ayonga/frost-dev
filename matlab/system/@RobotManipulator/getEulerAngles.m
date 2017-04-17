function [varargout] = getEulerAngles(obj, varargin)
    % Returns the symbolic representation of the Euler angles of a
    % rigid link.
    %
    % Parameters:
    % varargin: the name of the rigid links @type char
    % 
    % Return values:    
    %  ang: the 3-dimensional Euler angles (roll,pitch,yaw) vector of the
    %  CoM of the system @type SymExpression
    %
    %
    % @note Syntax for ont link
    %  
    % >> getEulerAngles(obj,'Link1')
    %
    % @note Syntax for multiple links
    % 
    % >> getEulerAngles(obj,{'Link1','Link2'})
    
    
    % the number of points (one less than the nargin)
    n_link = numel(varargin);
    if n_link>0
        links = cell(1,n_link);
        valid_link_name = {obj.Links.name};
        % validate the input arguments
        for i=1:n_link
            
            % validate parent link name (case insensitive)
            link_name= str2mathstr(validatestring(varargin{i},valid_link_name));
            links{i} = {link_name,[0,0,0]};
            
        end
        
        ang = eval_math_fun('ComputeEulerAngles',[links, {obj.SymTwists}]);
        
        varargout = cell(1,n_link);
        for i=1:n_pos
            varargout{i} = ang(i,:);
        end
    else
        varargout = {};
    end
    
end