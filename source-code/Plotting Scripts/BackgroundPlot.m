function [] = BackgroundPlot(app,Database, SetPoint)

%% interpolation of CV with LED pulser figure
ParInd = not(contains(Database.ParNames(1,:), ["FSC","SSC","Time","-H"]));
ParNams = Database.ParNames(1,ParInd);

%% plot background on vs. background off
fig = figure('units','normalized','position',[0 0 1 1],'visible','off');
t = tiledlayout('flow','tilespacing','compact','padding','compact');

BackgroundOffSD = Database.Set.Cond_0B.PN99.roSD(:,ParInd);
BackgroundOnSD = Database.Set.Cond_1B.PN99.roSD(:,ParInd);
maxY = 10^ceil(log10(max([BackgroundOffSD(:); BackgroundOnSD(:)].^2)));
ParInd2 = find(ParInd);
for i = 1:numel(ParNams)
    xData1 = Database.Set.Cond_0B.PN99.Vt(:,ParInd2(i));
    xData2 = Database.Set.Cond_1B.PN99.Vt(:,ParInd2(i));

    Outlier1 = xData1 == 0;
    Outlier2 = xData2 == 0;

    xData1 = xData1(~Outlier1);
    xData2 = xData1(~Outlier2);

    yData1 = BackgroundOffSD(~Outlier1,i).^2;
    yData2 = BackgroundOnSD(~Outlier2,i).^2;

    nexttile
    plot(xData1,yData1,'o-k','linewidth',2)
    hold on
    plot(xData2,yData2,'o-b','linewidth',2)

%     line([SetPoint{i+1} SetPoint(i)], [1 maxY],'color','r','linewidth',2)
    fill([repmat(SetPoint{i+1,2},1,2) repmat(SetPoint{i+1,3},1,2)], [1 maxY maxY 1],[0.8 0.5 0],'facealpha',0.2)

    grid on
    set(gca,'box','on','linewidth',2,'fontsize',14,'yscale','log')
    ylim([1 maxY])
    yticks(10.^(1:log10(maxY)))
    xticks(min([xData1(:);xData2(:)]):20:max([xData1(:);xData2(:)]))
    xtickangle(90)
    xlim([min([xData1(:);xData2(:)]) max([xData1(:);xData2(:)])])
    title([ParNams{i}],'FontSize',16)

end
ylabel(t, 'SD^2','FontSize',16,'FontWeight','bold')
xlabel(t, 'Voltage','FontSize',16,'FontWeight','bold')
nexttile
plot([nan nan],[nan nan],'o-k','linewidth',2)
hold on
plot([nan nan],[nan nan],'o-b','linewidth',2)
fill([nan nan],[nan nan],[0.8 0.5 0],'facealpha',0.2)
legend({'Background SD^2, lasers off','Background SD^2, lasers on','Set point voltage range'},'location','northwest','FontSize',15,'box','off')
axis off

ExportFigure(app,fig, 'Background')
close(fig)

end