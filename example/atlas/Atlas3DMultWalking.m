classdef Atlas3DMultWalking < HybridSystem
    % A hybrid system model for 3D multi-contact walking of ATLAS Robot
    
    properties
        
        sim_opts
        
    end
    
    
    methods
        function obj = Atlas3DMultWalking(model)
            % construct the hybrid system model for 3D multi-contact
            % walking of ATLAS Robot
            %
            % Parameters:
            % model: the left body model of ATLAS robot
           
            
            obj = obj@HybridSystem('AtlasFlatWalking', model);
            
            
            % domain objects
            right_ts_domain = RightTS3DMultiWalking(model);
            right_tl_domain = RightTL3DMultiWalking(model);
            right_hs_domain = RightHS3DMultiWalking(model);
            left_ts_domain = LeftTS3DMultiWalking(model);
            left_tl_domain = LeftTL3DMultiWalking(model);
            left_hs_domain = LeftHS3DMultiWalking(model);
            
            % guard objects
            left_toe_lift = LeftToeLift();
            left_heel_strike = LeftHeelStrike();
            left_toe_strike = LeftToeStrike();
            right_toe_lift = RightToeLift();
            right_heel_strike = RightHeelStrike();
            right_toe_strike = RightToeStrike();
            
            % control object
            io_control  = IOFeedback('IO');
            
            
            obj = addVertex(obj, 'RightToeStrike', 'Domain', right_ts_domain, ...
                'Control', io_control);
            obj = addVertex(obj, 'RightToeLift', 'Domain', right_tl_domain, ...
                'Control', io_control);
            obj = addVertex(obj, 'RightHeelStrike', 'Domain', right_hs_domain, ...
                'Control', io_control);
            obj = addVertex(obj, 'LeftToeStrike', 'Domain', left_ts_domain, ...
                'Control', io_control);
            obj = addVertex(obj, 'LeftToeLift', 'Domain', left_tl_domain, ...
                'Control', io_control);
            obj = addVertex(obj, 'LeftHeelStrike', 'Domain', left_hs_domain, ...
                'Control', io_control);
            
            srcs = {'RightToeStrike'
                'RightToeLift'
                'RightHeelStrike'
                'LeftToeStrike'
                'LeftToeLift'
                'LeftHeelStrike'};
            
            tars = {'RightToeLift'
                'RightHeelStrike'
                'LeftToeStrike'
                'LeftToeLift'
                'LeftHeelStrike'
                'RightToeStrike'};
            
            obj = addEdge(obj, srcs, tars);
            obj = setEdgeProperties(obj, srcs, tars, 'Guard',...
                {left_toe_lift,...
                left_heel_strike,...
                left_toe_strike,...
                right_toe_lift,...
                right_heel_strike,...
                right_toe_strike});
            
            % simulation options
            obj.sim_opts = struct;
            obj.sim_opts.numcycle = 1;
            obj.sim_opts.n_sample = 20;
        end
        
        
        function obj = loadParam(obj, param_config_file, model)
            
            
            old_params = cell_to_matrix_scan(yaml_read_file(param_config_file));
            params = cell(1,6);
            for i=1:6
                params{i}.a = old_params.domain(i).a;
                params{i}.v = old_params.domain(i).v;
                params{i}.p = old_params.domain(i).p(1:2)';
            end
            
            obj = setVertexProperties(obj, 1:6, 'Param',...
                params);
            
            old_dofs = {'BasePosX'
                'BasePosY'
                'BasePosZ'
                'BaseRotX'
                'BaseRotY'
                'BaseRotZ'
                'l_leg_hpz'
                'l_leg_hpx'
                'l_leg_hpy'
                'l_leg_kny'
                'l_leg_aky'
                'l_leg_akx'
                'r_leg_hpz'
                'r_leg_hpx'
                'r_leg_hpy'
                'r_leg_kny'
                'r_leg_aky'
                'r_leg_akx'};
            q0 = zeros(model.nDof,1);
            dq0 = zeros(model.nDof,1);
            q0_old = old_params.domain(1).x_plus(1:18);
            dq0_old = old_params.domain(1).x_plus(19:end);
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
            
        end
        
        function obj = simulate(obj)
           obj = simulate@HybridSystem(obj, obj.sim_opts); 
        end
    end
    
    
end