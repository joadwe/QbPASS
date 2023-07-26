function QbPASS_Folder_Check(app)

% get selpath
selpath = getpref(app.PrefName,'FileDirectory');

% check output folder exists
if ~isfolder(fullfile(selpath,'QbPASS Outputs'))
    mkdir(fullfile(selpath,'QbPASS Outputs'))
end

% check a folder for each cytometer exists in output folder
for i = 1:numel(app.SelectedCytometerDropDown.Items)
    
    if ~isfolder(fullfile(selpath,'QbPASS Outputs',app.SelectedCytometerDropDown.Items{i}))
        mkdir(fullfile(selpath,'QbPASS Outputs',app.SelectedCytometerDropDown.Items{i}))
    end
    
    % check a folder for each cytometer's datasets exists in output folder
    filepath = fullfile(getpref(app.PrefName,'FileDirectory'),app.SelectedCytometerDropDown.Items{i},'*.mat');
    files = dir(filepath);
    filenames = {files.name};
    ind = contains(filenames,'D_');
    filenames = filenames(ind);
    
    if isempty(filenames)
    else
        for ii = 1:numel(filenames)
        DispNames = cellstr([datestr(str2double(replace(filenames{ii},{'D_','.mat'},'')), 'yyyy-mm-dd'), ' Acquisition']);
        
        for ii = 1:numel(DispNames)
            if ~isfolder(fullfile(selpath,'QbPASS Outputs',app.SelectedCytometerDropDown.Items{i},DispNames{ii}))
                mkdir(fullfile(selpath,'QbPASS Outputs',app.SelectedCytometerDropDown.Items{i},DispNames{ii}))
            end
        end
    end
    
    
end



end