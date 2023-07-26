function [] = ExportTable(app, Table, TableName)

%% output figures
cytometer = app.SelectedCytometerDropDown.Items(app.SelectedCytometerDropDown.Value);
dataset = app.SelectedDatasetDropDown.Items(app.SelectedDatasetDropDown.Value);

OutputPath = char(fullfile(getpref(app.PrefName,'FileDirectory'),'QbPASS Outputs',cytometer,dataset));

if ~isfolder(OutputPath)
    mkdir(OutputPath)
end

writecell(Table, fullfile(OutputPath,[TableName,'.xlsx']))

end