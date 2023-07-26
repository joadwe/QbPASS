function [] = ElectronicLinearity(app, Database)


%% interpolation of CV with LED pulser figure
ParInd = not(contains(Database.ParNames(1,:), ["FSC","SSC","Time","-H"]));
ParNams = Database.ParNames(1,ParInd);

MedStats = Database.roMed(:,ParInd);

Voltages = Database.Vt(:,ParInd);

PulseIntUq = Database.Set.Cond_1L.PulserInt;
PulseIntIndex = cellfun(@str2num, Database.PulserInt);

maxY = 2^18;
Threshold = maxY*0.9;

%% plot background on vs. background off
fig = figure('units','normalized','position',[-1 0 1 1],'visible','off');
t = tiledlayout('flow','tilespacing','compact','padding','compact');

colororder({'k','k'})
for i = 1:numel(ParNams)
    plotted = 0; % reset plot for new parameter
    for ii = 1:numel(PulseIntUq)

        yData = MedStats(PulseIntIndex==PulseIntUq(ii),i);
        xData = Voltages(PulseIntIndex==PulseIntUq(ii),i);

        if max(yData) > Threshold
        elseif plotted == 1 % optimal parameter already plotted
        else

            reg = robustfit(log10(xData(end-5:end)), log10(yData(end-5:end))); % perform regression on data
            fitted = 10.^((log10(xData)*reg(2)) + reg(1)); % get predicted extrapolation

    
            nexttile
            yyaxis left
            plot(xData(:), fitted, '-k','linewidth',2)
            hold on
            plot(xData(:), yData(:), '.k','MarkerSize',15)




            set(gca, 'yscale','log','box','on','Fontsize',14, 'linewidth',2)
            title([ParNams{i}, ' ', num2str(PulseIntUq(ii)),' dB Intensity'])
            ylim([1 maxY])
            yticks(10.^(0:log10(maxY)))
            xlim([min(xData) max(xData)])

            yyaxis right
            xData2 = Voltages(PulseIntIndex==PulseIntUq(ii+1),i);
            ydata2 = MedStats(PulseIntIndex==PulseIntUq(ii+1),i);
            ratio = yData ./ ydata2(ismember(xData2, xData));
            ylim([0 2])

            plot(xData, ratio, 'or','markerfacecolor','r')
            plotted = 1;
        end

    end

end
ylabel(t, 'Channel No.','FontSize',16,'FontWeight','bold')
xlabel(t, 'Voltage','FontSize',16,'FontWeight','bold')

nexttile
plot([nan nan],[nan nan],'-k','linewidth',2)
hold on
plot([nan nan],[nan nan],'.k','MarkerSize',15)
plot([nan nan],[nan nan],'or','markerfacecolor','r')

legend({'Predicted Linearity','Median Intensity','Intensity Ratio'},'location','northwest','FontSize',15,'box','off')
axis off

ExportFigure(app,fig, 'Electronic Linearity')
close(fig)

end