function [StatsExport] = SetPointPlot(app,Database)

devMode = 'on';

%% interpolation of CV with LED pulser figure
ParInd = not(contains(Database.ParNames(1,:), ["FSC","SSC","Time","-H"]));
ParNams = Database.ParNames(1,ParInd);

%% plot background on vs. background off
fig = figure('units','normalized','position',[-1 0 1 1],'visible','off');
t = tiledlayout('flow','tilespacing','compact','padding','compact');

BackgroundOnSD = Database.Set.Cond_1B.PN99.roSD(:,ParInd);
maxY = 2^18;
ParInd2 = find(ParInd);

StatsExport = cell(size(BackgroundOnSD,2)+1, 3);
StatsExport(1,:) = {'Parameter','Lower Set Point','Upper Set Point'};
for i = 1:numel(ParNams)
    Vt.Raw = Database.Set.Cond_1B.PN99.Vt(:,ParInd2(i));
    Bckgrd.Raw = BackgroundOnSD(:,i);

    [Vt, Bckgrd] = removeSignalOutliers(Vt, Bckgrd);

    [Vt, Bckgrd] = ObtainSetpoints(Vt, Bckgrd);

    DR = 10.^(log10(2^18)-log10(Bckgrd.Raw));

    nexttile
    colororder({'k','k'})
    fill([repmat(Vt.Setpoint(1),1,2) repmat(Vt.Setpoint(2),1,2)], [1 maxY maxY 1],[0.8 0.5 0],'facealpha',0.2)
    hold on
    plot(Vt.Raw, Bckgrd.Raw,'o-b','linewidth',2)

    switch devMode
        case 'on'
            line(10.^Vt.Spline, 10.^ Bckgrd.MinExtrp,'color','r','linestyle','--','linewidth',2)
            line(10.^Vt.Spline, 10.^ Bckgrd.MaxExtrp,'color','r','linestyle','--','linewidth',2)
    end

    plot(Vt.Raw, DR,'-x','linewidth',2,'color','k')

    grid on
    set(gca,'box','on','linewidth',2,'fontsize',14,'yscale','log')

    % x axis formatting
    xticks(min([Vt.Raw(:)]):40:max([Vt.Raw(:)]))
    xtickangle(90)
    xlim([min(Vt.Raw(:)) max(Vt.Raw(:))])

    % yaxis formatting
    yticks(10.^(0:log10(maxY)))
    ylim([1 maxY])
    title([ParNams{i},' - ',num2str(Vt.Setpoint(1)),'-',num2str(Vt.Setpoint(2)),'V'],'FontSize',16)
    set(gca,'yscale','log')

    StatsExport(i+1,:) = [ParNams{i}, {Vt.Setpoint(1)} {Vt.Setpoint(2)}];

    fname = replace(ParNams{i},'-A','');
    Export.(fname).Vt = Vt;
    Export.(fname).Bckgrd = Bckgrd;
end
save('Export Data.mat','Export')

ylabel(t, 'Channel No.','FontSize',16,'FontWeight','bold')
xlabel(t, 'Voltage','FontSize',16,'FontWeight','bold')

nexttile
plot([nan nan],[nan nan],'o-b','linewidth',2)
hold on
plot([nan nan],[nan nan],'o-k','linewidth',2)
fill([nan nan],[nan nan],[0.8 0.5 0],'facealpha',0.2)
plot([nan nan],[nan nan],'o-','linewidth',2,'Color',[0 0.5 0])

legend({'Background SD, lasers on','Dynamic Range','Set point voltage'},'location','northwest','FontSize',15,'box','off')
axis off


ExportTable(app, StatsExport, 'Set Point Range')
ExportFigure(app,fig, 'Set Point Voltage Range')
close(fig)

end
