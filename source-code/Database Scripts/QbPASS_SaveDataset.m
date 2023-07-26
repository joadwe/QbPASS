function QbPASS_SaveDataset(app, Database)

path = char(getpref(app.PrefName,'FileDirectory'));
folder = app.SelectedCytometerDropDown.Items{app.SelectedCytometerDropDown.Value};
date = ['D_',num2str(datenum(Database.AcqDate(1)))];
filename = char(fullfile(path,folder,[date,'.mat']));

save(filename,'Database','-v7.3')

UpdateName = [datestr(str2double(replace([date,'.mat'],{'D_','.mat'},'')), 'yyyy-mm-dd'), ' Acquisition'];

if isempty(app.SelectedDatasetDropDown.Items)
    DatasetVal = 1;
else
    DatasetVal = app.SelectedDatasetDropDown.Value + 1;
end
UpdateDatasets(app,DatasetVal);

end

