function [] = DetectorLinearity(app, Database)

Thresh.CV = getpref(app.PrefName,'Threshold_CV');
Thresh.Voltage = getpref(app.PrefName,'Threshold_Voltage');

%% interpolation of CV with LED pulser figure
Selected_Cond = 'Cond_1L';
ParInd = not(contains(Database.ParNames(1,:), ["FSC","SSC","Time","-H"]));
ParNams = Database.ParNames(1,ParInd);

maxY = 2^18;

PulseIntFields = Database.Set.(Selected_Cond).PulseIntFields;
Med = [];
PInt = [];
for i = 1:numel(PulseIntFields)
    vtInd = Database.Set.(Selected_Cond).(PulseIntFields{i}).Vt(:,ParInd) == Thresh.Voltage;
    tempMed = Database.Set.(Selected_Cond).(PulseIntFields{i}).roMed(:,ParInd);
    Med = [Med; tempMed(vtInd)'] ;
    PInt = [PInt; repmat(str2num(replace(PulseIntFields{i},{'P','N'},{'','-'})), 1, numel(tempMed(vtInd)))];
end

fig = figure('units','normalized','position',[0 0 1 1],'visible','off');
t = tiledlayout('flow','tilespacing','compact','padding','compact');
colororder({'k','k'})
for i = 1:size(Med,2)
    nexttile
    xData = PInt(:,i);
    yData = Med(:,i);

    if min(yData) <4

        yyaxis left
        plot(xData,yData,'.k','linewidth',2,'MarkerSize',15)

        set(gca,'yscale','log','linewidth',2,'FontSize',14,'box','on')
        title([ParNams{i},', ',num2str(Thresh.Voltage),'V'],'FontSize',16)
        xlim([-100 0])
        yticks(10.^(0:log10(maxY)))
        ylim([1 maxY])

        yyaxis right
        Norm.diff = yData;
        Norm.diff = Norm.diff(2:end)./Norm.diff(1:end-1);
        Norm.diff = sqrt(Norm.diff.^2);
        Norm.xDataCent = xData(2:end) - diff(xData)/2;

        plot(Norm.xDataCent,Norm.diff,'.r','MarkerSize',15)
        hold on
        plot([-100 0], repmat(median(Norm.diff(~isnan(Norm.diff))),1,2),':r','linewidth',2)
        set(gca,'yscale','log','linewidth',2,'FontSize',14,'box','on')
        title([ParNams{i},', ',num2str(Thresh.Voltage),'V'],'FontSize',16)
        xlim([-100 0])
        ylim(10.^[-1 1])

    else
        title([ParNams{i},', ',num2str(Thresh.Voltage),'V'],'FontSize',16)
        set(gca,'XColor','none','YColor','none','TickDir','out','Color','none')
    end

end

xlabel(t, "Pulser Intensity (db)",'FontSize',15)
ylabel(t, 'Channel No.','FontSize',15)
nexttile
plot([nan nan],[nan nan],'.k','linewidth',2, 'MarkerSize',15)
hold on
plot([nan nan],[nan nan],'.r','linewidth',2, 'MarkerSize',15)
plot([nan nan],[nan nan],':r','linewidth',2)

legend({'Median Intensity','fold-change','median fold change'},'location','northwest','FontSize',15,'box','off')
axis off

ExportFigure(app,fig, 'Detector Linearity')
close(fig)


end