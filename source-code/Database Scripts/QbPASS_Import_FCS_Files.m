function [proceed] = QbPASS_Import_FCS_Files(app)

app.ImportSelpath = uigetdir();

if length(app.ImportSelpath) <= 1
    proceed = false;
else
    
    % get filenames from directory
    Files = dir([app.ImportSelpath,'/*.fcs']);

    [Files]=QbPASS_FileImportCheck(app,Files);

    % create string to import files
    Filenames = strcat({Files.folder},{'/'},{Files.name});

    % give error message if no fcs files are in the directory
    if numel(Filenames) == 0
        uialert(app.QbPASS_UI,'No .fcs files found in folder','Invalid Folder');
        proceed = false;
    else

        % get fcs file stats
        [app, Dataset, d, var] = QbPASS_ProcessFiles(app, Filenames);

        % save dataset
        QbPASS_SaveDataset(app, Dataset.(var))

        close(d)
        proceed = true;
    end
end


end