classdef animator
    % This class defines a simple basic animator objects for multi-body
    % mechanical systems (a.k.a. robots). 
    
    
    properties
        % Options for animation
        %
        % @type struct
        Options
        
        
        % The ground plot options
        %
        % @type Ground
        Ground
        
        
        % The line objects to be plotted
        %
        % @type struct array
        LineObjects
        
    end
    
    methods
        
        function obj = animator(model, options, ground)
            % The constructor function
            
            
            obj.LineObjects = model.LineObjects;
            
            obj.Options = struct(...
                'RealTime', true,...
                'SaveToFile', true,...
                'FileType', 'avi',...
                'FrameRate', 60, ...
                'ViewAngle', [0,0],...
                'DoSleep', true);
            if nargin > 1
                obj.Options = struct_overlay(obj.Options, options);
            end
            
            obj.Ground = struct(...
                'Size', [10, 1],...
                'MeshSize', 0.1,...
                'Height', 0);
            if nargin > 2
                obj.Ground = struct_overlay(obj.Ground, ground);
            end
        end
        
        function obj = setOption(obj, varargin)
            
            
            if nargin > 1
                options = struct(varargin{:});
            
                obj.Options = struct_overlay(obj.Options, options);
            end
        end
        
        function fig_hl = animate(obj, flow, output_file)
            % Run the animation
            
            if nargin < 3
                output_file = '/tmp/anim_output.avi';
            end
            % Before run the animator, first parse the input flow data
            [traj,axis_offset] = parse(obj, flow);
            ground = obj.Ground;
            options = obj.Options;
            line_obj = obj.LineObjects;
            
            
            if options.SaveToFile
                writerObj = VideoWriter(output_file);
                writerObj.FrameRate = options.FrameRate;
                open(writerObj);
            end
            
            % initialize the figure object
            fig_hl=figure(1000); clf
            set(fig_hl, 'WindowStyle', 'normal');
            set(fig_hl,'Position', [200 80 560 720]); % for making movies
            clf;
            
            hold all;
            grid on
            axis equal
            anim_axis=[-1 1 -0.5 0.5 -0.3 1.7];
            
            axis(anim_axis);
            view(options.ViewAngle);
            
            
            g_x = -1:ground.MeshSize:ground.Size(1)-1;
            g_y = -ground.Size(2)/2:ground.MeshSize:ground.Size(2)/2;
            g_z = 0;
            
            [g_X,g_Y,g_Z] = meshgrid(g_x, g_y, g_z);
            
            g = surf(g_X,g_Y,g_Z,'FaceColor','none','EdgeAlpha',0.5);
            set(gcf,'Renderer','zbuffer');
            n_line  = length(line_obj);
            anim_line = cell(1,n_line);
            for i=1:n_line
                anim_line{i} = plot3(traj{1,i}{1}(1,:),traj{1,i}{1}(2,:),traj{1,i}{1}(3,:),...
                    line_obj(i).Style,...
                    'Color',line_obj(i).Color,...
                    'MarkerFaceColor',line_obj(i).Color,...
                    'MarkerSize',line_obj(i).MarkerSize,...
                    'LineWidth',line_obj(i).LineWidth);
            end
            
            
            tic();
            lastTime = toc();
            frameDt = 1 / options.FrameRate;
            n_phase = length(flow);
            for i = 1:n_phase
                if isempty(flow{i}.calcs)
                    continue;
                end
                
                offset = axis_offset{i};
                
                n_pts     = numel(traj{i,1});
                for j = 1:n_pts
                    
                    for k = 1:n_line
                        set(anim_line{k}, 'XData', traj{i,k}{j}(1,:), ...
                            'YData',  traj{i,k}{j}(2,:), 'ZData',  traj{i,k}{j}(3,:));
                    end
                    
                    
                    new_axis = anim_axis + [offset(j) offset(j) 0 0 0 0];
                    
                    axis(new_axis);
                    
                    
                    
                    
                    drawnow;
                    
                    if options.DoSleep
                        dt = toc() - lastTime;
                        sleepTime = frameDt - dt;
                        if sleepTime > 0
                            pause(sleepTime);
                        end
                    end
                    lastTime = lastTime + frameDt;
                    
                    if options.SaveToFile
                        frame = getframe(gcf);
                        writeVideo(writerObj,frame);
                    end
                end
                
                
            end
            
            if options.SaveToFile
                close(writerObj);
            end
        end
        
        function [traj, axis_offset] = parse(obj, flow)
            
            assert(iscell(flow),...
                'The trajectory data must be given as a cell array');
            
            n_phase = length(flow);
            n_line  = length(obj.LineObjects);
            traj = cell(n_line,n_phase);
            axis_offset = cell(1,n_phase);
            for i = 1:n_phase
                
                
                % even sample
                calcs = horzcat_fields([flow{i}.calcs{:}]);
                if isempty(calcs)
                    continue;
                end
                [t_s, x_s] = even_sample(calcs.t, calcs.qe, obj.Options.FrameRate);
                n_sample = length(t_s);
                pos_data = cell(1,n_sample);
                for k=1:n_line
                    line_obj = obj.LineObjects(k);
                    
                    n_point = line_obj.NumPoint;
                    funcs = line_obj.Kin.Funcs;
                    for j=1:n_sample
                        pos = feval(funcs.Kin, x_s(:,j));
                        pos_data{j} = reshape(pos,3,n_point);
                    end
                    
                    traj{i,k} = pos_data;
                end
                axis_offset{i} = x_s(1,:);
                
            end
        end
    end
end