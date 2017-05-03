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
        
        
        function obj = loadParam(obj, param_config_file, model)
            
            
            old_params = cell_to_matrix_scan(yaml_read_file(param_config_file));
            params = cell(1,1);
            for i=1:1
                params{i}.a = old_params.domain(i).a;
                params{i}.v = old_params.domain(i).v;
                params{i}.p = old_params.domain(i).p(1:2)';
            end
            
            obj = setVertexProperties(obj, 1:1, 'Param',...
                params);
            
            old_dofs = {'BasePosX'
                'BasePosY'
                'BasePosZ'
                'BaseRotX'
                'BaseRotY'
                'BaseRotZ'
                'shoulder_pan_joint'
                'shoulder_lift_joint'
                'elbow_joint'
                'wrist_1_joint'
                'wrist_2_joint'
                'wrist_3_joint'};
            q0 = zeros(model.nDof,1);
            dq0 = zeros(model.nDof,1);
            q0_old = old_params.domain(1).x_plus(1:model.nDof);
            dq0_old = old_params.domain(1).x_plus(model.nDof+1:end);
            for i=1:model.nDof
                idx = find(strcmp(model.Dof(i).name,old_dofs));
                if isempty(idx)
                    q0(i) = 0;
                    dq0(i) = 0;
                else
                    q0(i) = q0_old(idx);
                    dq0(i) = dq0_old(idx);
                end
            end
            
            obj.sim_opts.x0 = [q0;dq0];
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