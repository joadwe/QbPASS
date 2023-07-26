function QbPASS_Output_Plots(app)
f = 0;
Thresh.CV = getpref(app.PrefName,'Threshold_CV');
Thresh.Voltage = getpref(app.PrefName,'Threshold_Voltage');


cytometer =  app.SelectedCytometerDropDown.Items{app.SelectedCytometerDropDown.Value};
dataset = app.SelectedDatasetDropDown.Items{app.SelectedDatasetDropDown.Value};

date = ['D_',num2str(datenum(replace(dataset,' Acquisition','')))];

filename = char(fullfile(getpref(app.PrefName,'FileDirectory'),cytometer,[date,'.mat']));

load(filename);

% try
ElectronicLinearity(app, Database)

DetectorLinearity(app, Database)


[SetPoint] = SetPointPlot(app,Database);

BackgroundPlot(app,Database, SetPoint)

% catch
%     f = 1;
% end

if f ==0
    uialert(app.QbPASS_UI,'Dataset import sucessful','Dataset Import','Icon','success')
else
    uialert(app.QbPASS_UI,'Dataset import unsucessful','Dataset Import','Icon','error')
end

OutputPath = char(fullfile(getpref(app.PrefName,'FileDirectory'),'QbPASS Outputs',dataset));

%% open mac finder to correct folder
if ismac()
    system(['open ''',OutputPath,'''']);
end

end