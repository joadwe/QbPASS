function ExportFigure(app,fig, FigName)

%% output figures
cytometer = app.SelectedCytometerDropDown.Items(app.SelectedCytometerDropDown.Value);
dataset = app.SelectedDatasetDropDown.Items(app.SelectedDatasetDropDown.Value);

OutputPath = char(fullfile(getpref(app.PrefName,'FileDirectory'),'QbPASS Outputs',cytometer,dataset));

if ~isfolder(OutputPath)
    mkdir(OutputPath)
end

fig.PaperOrientation = 'landscape';
fig.PaperSize = [20 14.14];
fig.PaperUnits = 'normalized';
fig.PaperPosition = [0 0 1 1];
fig.Renderer = "painters";

switch getpref(app.PrefName,'outputFormat')
    case 'ps'
        exportgraphics(fig, fullfile(OutputPath,[FigName,'.pdf']),"ContentType","vector","Resolution",150);
    case 'jpeg'
        exportgraphics(fig, fullfile(OutputPath,[FigName,'.pdf']));
end

end