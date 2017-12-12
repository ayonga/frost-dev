function ret=plotthedata(xdata,ydata,xstring,ystring,varargin)


        fignum=100;
        narg=length(varargin)/2;
        if mod(length(varargin),2)~=0
            error('What is wrong with you? There are odd number of arguments');
        end
        plotsurface=0;
        
        for i=1:narg
            switch varargin{2*i-1}
                case 'fignum'
                    fignum=varargin{2*i};
                case 'footer'
                    footer=varargin{2*i};
                case 'header'
                    header=varargin{2*i};
                case 'plottype'
                    if strcmp(varargin{2*i},'3D')
                        plotsurface=1;
                    end
                case 'humandata'
                    hdata=varargin{2*i};
                otherwise
                    error('What is wrong with you? You have input arguments which I cannot recognize');
            end
        end
                    
                    
            if plotsurface==0
                
                        linwid=2;
                        numplots=size(ydata,1);
                        h = figure(fignum); 
                        clf;
                        set(h,'position',[100 100 1.0*560 1.0*400]);
                        horizontallabelposition=[0.07 0.60];

                        colorinput={'b-';'r-'};
                        for i=1:numplots
                            hs(i) = plot(xdata,ydata(i,:),colorinput{i});
                             set(hs(i),'MarkerSize',6,'LineWidth',linwid);
                             hold on;
                        end
                        %axis([0 .63 0 1.2])

set(gca,'FontSize',12);
                        %%%%%%%%%%%%%%%%%%% Labels / Legend %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        xlabel(xstring,'Interpreter','LaTex','FontSize',30);
                %         for i=1:numplots
                        ylabel(ystring,'Interpreter','LaTex','FontSize',30);
                %         end
                        % title('\bf{Robustness - Simulation vs Experiment}','Interpreter','LaTex','FontSize',16);
                        
                        apc = [0.17000000000000   0.165000000000   0.823000000000000   0.720000000000000];
                        set(gca,'position',apc);
                        ah1 = gca;
                          if fignum==8
                            axis([xdata(1) xdata(end) -0.30 0.3]);
                        % % %Top Left
                          else
                        axis([xdata(1) xdata(end) min(ydata(:))-0.05 max(ydata(:))+0.05]);
                          end
                        for i=1:numplots
                        ah1=axes('position',get(gca,'position'), 'visible','off');

                        l(i) = legend(ah1, hs(i),footer{i},'Location','SouthOutside');
                        set(l(i),'Orientation','Horizontal','Box','off','FontSize',25,'Interpreter','LaTeX');
                        p = get(l(i),'position');
                        set(l(i), 'position', [horizontallabelposition(i) p(2)-.88 1.41 p(4)+.05],'Box','off');
                        l_child1 = get(l(i),'Children');
                        for j = 1:length(l_child1)
                            if strcmp( get(l_child1(j),'Type'),'text')
                                set(l_child1(j),'FontSize',30,'Interpreter','LaTeX')
                            end
                        end
                        end
            else
                nsteps=length(xdata);
                h=figure(fignum);
                clf;
                set(h,'position',[100 100 1.0*500 1.0*400]);
                hx=gca;
                apc = [0.1800000000000   0.18000000000000   0.72000000000000   0.720000000000000];
                set(hx,'position',apc);
                
                if fignum==40
                    hdata.up=0.2*ones(size(hdata.upperB));
                    hdata.low=-0.1*ones(size(hdata.lowerB));
                else
                    hdata.up=hdata.upperB;hdata.low=hdata.lowerB;
                end
                       
                for i=1:nsteps
                    if (max(ydata{i}(:,1))<max(hdata.up)) && (min(ydata{i}(:,1))>min(hdata.low))
                    p(i) = plot3(ydata{i}(:,2),xdata{i},ydata{i}(:,1),'r-');
                    hold on;
                    end
                end

                nominal_velocity = 0.14318;
                CrossSec_T = [0 0.574 0.574 0];
                CrossSec_Step = length(xdata)*ones(4);
                CrossSec_Z(1,:) = [-0.6 -0.6 0.6 0.6];
                CrossSec_Z(2,:) = [-0.1 -0.1 2.3 2.3];
                CrossSec_Z(3,:) = [min(hdata.low) min(hdata.low) max(hdata.up) max(hdata.up)];
                CrossSec_C = [0 0 0 0];

                patch(CrossSec_Step, CrossSec_T,...
                        CrossSec_Z(3,:),CrossSec_C,...
                            'FaceAlpha', 0.5, 'EdgeAlpha', 0,'FaceColor', [.5 .5 1]);   
                patch([length(xdata)*ones(size(hdata.ave_time)),length(xdata)*ones(size(hdata.ave_time))],...
                    [hdata.ave_time,fliplr(hdata.ave_time)],...
                    [hdata.lowerB,fliplr(hdata.upperB)],...
                    [length(xdata)*ones(size(hdata.ave_time)),length(xdata)*ones(size(hdata.ave_time))],'FaceColor', [.5 .5 1]);
                plot3(length(xdata)*ones(size(hdata.ave_time)),hdata.ave_time,hdata.x_mean,'k-');
                                hx=gca;
                view([-54 20])
                set(hx,'Xgrid','on','Ygrid','on','Zgrid','on',...
                    'Xlim',[0 length(xdata)],'Ylim',[0 0.574],'Zlim',[min(hdata.low) max(hdata.up)]);
                xlabel(ystring{2},'Interpreter','LaTex','FontSize',30);
                ylabel(xstring,'Interpreter','LaTex','FontSize',30);
                zlabel(ystring{1},'Interpreter','LaTex','FontSize',30);
                set(get(hx,'Title'),'String',header,'Interpreter','LaTex','FontSize',30);
                zpos=get(get(hx,'zlabel'),'position');
                zpos(1)=zpos(1)-20;
                                xpos=get(get(hx,'xlabel'),'position');
                xpos(1)=xpos(1)-15;
                xpos(2)=xpos(2)+0.1;
                set(get(hx,'zlabel'),'position',zpos);
                set(get(hx,'xlabel'),'position',xpos);
%                 set(get(hx,'Title'),'Position',[0.7821    0.5664    3.543]);

             end

end