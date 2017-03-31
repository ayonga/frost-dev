classdef SecondOrderSystem < DynamicalSystem
    % A second-order affine dynamical system    
    % The second order dynamical system has a form:
    % \f{eqnarray*}{
    % M(q)\ddot{q}= f(q,\dot{q}) + g(q)u + h(q)lambda
    % \f}
    %
    % @author ayonga @date 2017-02-26
    % 
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause 
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    properties
        
        
    end
    
    
    
    methods
        function obj = SecondOrderSystem(varargin)
             % The class construction function
            %
            % Parameters:
            % varargin: the variable input arguments.
            %  Name: the name of the system @type char
            %  nState: the number of state variables @type integer
            %  nControl: the number of control inptus @type integer
            %  nExternal: the number of external inputs @type integer
            
            % parse input arguments
            ip = inputParser;
            ip.addRequired('Name',@ischar);
            ip.addRequired('nState',@(x) isscalar(x) && isreal(x) && rem(x,1)==0 && x > 0);
            ip.addOptional('nControl',0,@(x) isscalar(x) && isreal(x) && rem(x,1)==0 && x>=0);
            ip.addOptional('nExternal',0,@(x) isscalar(x) && isreal(x) && rem(x,1)==0 && x>=0);
            ip.parse(varargin{:});
    
            args = ip.Results;
            
            % construct the object using superclass constructor
            obj = obj@DynamicalSystem(args.Name);
            
            % state variables
            x = SymVariable('x',[args.nState,1]);
            dx = SymVariable('dx',[args.nState,1]);
            ddx = SymVariable('ddx',[args.nState,1]);
            obj = obj.addState(x,dx,ddx);
            
            
            % control inputs
            u = SymVariable('u',[args.nControl,1]);
            if args.nExternal == 0
                obj = obj.addInput(u);
            else
                F = SymVariable('f',[args.nExternal,1]);
                obj = obj.addInput(u,F);
            end
            
            
        end
        
    end
    
    methods
        
        
        
        
        
    end
    
end

