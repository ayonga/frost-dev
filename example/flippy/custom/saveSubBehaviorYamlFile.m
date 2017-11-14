function [result,statessend,pose_start,pose_end] = saveSubBehaviorYamlFile(flow,info,save_file,save_solution_in_file,solution_in_file)
        flippy = flow.nlp.Plant;
        tspan = flow.t;
        states = flow.states;
        params = flow.params;
        sol = flow.sol;
        
        
        %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%% Save param in a yaml file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        param = cell(1,1);
        param{1}.name = 'FanucBurgerFlippyTrajectory';
        polydegree = flippy.VirtualConstraints.pos.PolyDegree;
        num2degree = flippy.VirtualConstraints.pos.Dimension;
        param{1}.a    = reshape(params.apos,num2degree,polydegree+1);
        if isfield(params,{'params.ppos'}), param{1}.p    = params.ppos;
        else, param{1}.p = [tspan(end), tspan(1)];end
        param{1}.v    = [];
        param{1}.x_plus = [states.x(:,1);states.dx(:,1)]';
        param{1}.x_minus = [states.x(:,end);states.dx(:,end)]';
        param{1}.sol = sol;

        if save_solution_in_file && info.status==0
            param_save_file = save_file;
            if solution_in_file
                prompt = 'Do you want to replace existing saved trajectory? y/n [n]: ';
                str = input(prompt,'s');
                if isempty(str)
                    str = 'n';
                end
                if strcmp(str,'y')
                    yaml_write_file(param_save_file,param);
%                     disp('The names of the files contain starting and ending position of end effector only.');
                else
                    disp('Saving canceled.');
                end
            else
                yaml_write_file(param_save_file,param);
            end
        end
        
        nparam = size(param{1}.a,2);
        r = [param{1}.p(1),zeros(1,nparam-1);param{1}.a];
        
        result = r;
        q_end = states.x(:,end);
        q_start = states.x(:,1);
        statessend.q_end = q_end;
        statessend.q_start = q_start;
        statessend.dq_end = states.dx(:,end);
        statessend.dq_start = states.dx(:,1);
        
        pose_end.position = [endeffx_sca_LR(q_end),endeffy_sca_LR(q_end),endeffz_sca_LR(q_end)];
        pose_end.orientation = [0,0,0];
        pose_start.position = [endeffx_sca_LR(q_start),endeffy_sca_LR(q_start),endeffz_sca_LR(q_start)];
        pose_start.orientation = [0,0,0];
end