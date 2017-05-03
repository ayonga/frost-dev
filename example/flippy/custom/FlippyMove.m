classdef FlippyMove < HybridSystem
    % A hybrid system model for 3D multi-contact walking of ATLAS Robot
    
    properties
        
        sim_opts
        
    end
    
    
    methods
        function obj = FlippyMove(model)
            % construct the hybrid system model for FLIPPY
            %
            % Parameters:
            % model: the hybrid system model of the FLIPPY robot
                       
            obj = obj@HybridSystem('FlippyMove', model);
            
            
%             % domain objects
%             pick_burger           = FlippyPickBurger(model);
            flip_place_burger = FlippyFlipPlaceBurger(model);
             
            % guard objects
%             grab_burger = GrabBurger(model);
            drop_burger = DropBurger(model);
            
            % control object
            io_control  = IOFeedback('IO');
            
            
            obj = addVertex(obj, 'FlippyFlipPlaceBurger', 'Domain', flip_place_burger, ...
                'Control', io_control);
%             obj = addVertex(obj, 'FlippyFlipPlaceBurger', 'Domain', flip_place_burger, ...
%                 'Control', io_control);
            
            srcs = {'FlippyFlipPlaceBurger'};
            
            tars = {'FlippyFlipPlaceBurger'};
            
            obj = addEdge(obj, srcs, tars);
            obj = setEdgeProperties(obj, srcs, tars, 'Guard',...
                {drop_burger});
            
            % simulation options
            obj.sim_opts = struct;
            obj.sim_opts.numcycle = 1;
            obj.sim_opts.n_sample = 20;
        end
        
        
        
        
        function obj = compile(obj, model, export_path)
            
            model.initialize();
            
            domains = obj.Gamma.Nodes.Domain;
            for i=1:numel(domains)
                compile(domains{i}, model, true);
                export(domains{i}, export_path, true);
            end
            
            guards = obj.Gamma.Edges.Guard;
            for i=1:numel(guards)
                compile(guards{i}, model, true);
                export(guards{i}, export_path, true);
            end
            
        end
        
        function obj = simulate(obj)
           obj = simulate@HybridSystem(obj, obj.sim_opts); 
        end
    end
    
    
end