function ret = plotdatasimple(xdata1,ydata1,xdata2,ydata2,label_x,label_y,fignum,savefile,location)

    
    hs25=figure(fignum);
    clf;
    set(hs25,'position',[100 100 1.0*540 0.9*400]);
    horizontallabelposition=[0.07 0.60];
    %
    hs = plot(xdata1,ydata1,'*',xdata2,ydata2);
    %                  axis([0 20 -0.1 100])
    set(gca,'FontSize',12);
    set(hs,'MarkerSize',6,'LineWidth',2);
    xlabel(label_x,'Interpreter','LaTeX','Fontsize',20);
    ylabel(label_y,'Interpreter','LaTeX','Fontsize',20);
    legend({'$Experiment$','$Simulation$'},'Interpreter','LaTeX','FontSize',13,'Location',location);
    grid on;

    apc = [0.175000000000000   0.19000000000   0.813000000000000   0.780000000000000];
    set(gca,'position',apc);

    if savefile
        filename = fullfile('/home/shishirny/repos/Papers/Figures/Flippy/Experiment',label_y);
        print(filename,'-depsc');
    end


end