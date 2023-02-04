function PlotTrajectories(qAll, vAll, indices)
    for i = 1:length(indices)
        f = figure;
        ax = axes(f); %#ok<LAXES>
        hold on;
        
        for j = 1:length(vAll)
            qi = reshape(qAll(j, indices(i), :), 1, size(qAll, 3));
            t = linspace(0, 1, size(qAll, 3));
            v = vAll(j).*ones(1, size(qAll, 3));
            
            plot3(ax, t, v, qi);
        end
        
        view(ax, 3);
        
        title(sprintf('Joint %d', indices(i)));
        xlabel('t');
        ylabel('v');
        zlabel('q');
        f.Name = ax.Title.String;
    end
end
