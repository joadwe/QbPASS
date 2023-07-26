function []=QbPASS_Preference_Check(app)

% get preference directory on computer
mcrpath = prefdir();
filenames = dir(mcrpath);
filenames = filenames(~ismember({filenames(:).name}, {'.', '..'}));

% make preference directory have read/write permission
for i = 1:size(filenames, 1)
    fileattrib(fullfile(prefdir(), filenames(i).name), '+w', 'u')
end

if ispref(app.PrefName) == 1 % if QbPASS preferences exist

    FileDirectoryCheck(app) % Check file directory from preferences
    if ispref(app.PrefName,'version') == 1
    else
        setpref(app.PrefName,'version', app.version)
    end
    PrefVersionUpdate(app)

else

    PrefVersionUpdate(app)
    [answer] = DirectoryDlg(app);

    % Handle response
    switch answer
        case 'Select Directory'
            selpath = uigetdir;
            if selpath == 0
            else
                setpref(app.PrefName,'FileDirectory',selpath)
            end

    end
end

Pref = getpref(app.PrefName);  % retrieve preferences
end


function PrefVersionUpdate(app)

Prefs = {'GUI_ExtPlot','on';...
    'ExclusionParameters',{'FSC','SSC','Time'};...
    'Threshold_Grad',50;...
    'Threshold_Channel',50;...
    'Threshold_CV',3.16;...
    'Threshold_Voltage',500;...
    'Target',150000;...
    'Phi_Threshold',[0.8 0.9];...
    'PhiNormLaser', 'on';...
    'FigLabel_FontSize', 'default';...
    'FigLabel_FontWeight', 'bold';...
    'FigTitle_FontSize', 'default';...
    'FigTitle_FontWeight', 'bold';...
    'FigAxes_FontSize', 'default';...
    'FigAxes_FontWeight', 'normal';...
    'VoltPlotStat', 'SD^2';...
    'outputFormat', 'ps';...
    'DeveloperAccess','off'};

setpref(app.PrefName,'version', app.version)

for i = 1:size(Prefs,1)

    if ispref(app.PrefName,Prefs{i,1}) == 1
    else
        setpref(app.PrefName, Prefs{i,1}, Prefs{i,2})
    end

end

end

function [answer] = DirectoryDlg(app)
answer = uiconfirm(app.QbPASS_UI,{'A folder containing your database files has not been found.', newline,'Select a folder where your database files are located or where you would like them saved'}, ...
    'Specify Directory','Options',{'Select Directory'},'Icon','warning');
end
