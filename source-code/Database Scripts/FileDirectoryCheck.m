function FileDirectoryCheck(app)

if ispref(app.PrefName,'FileDirectory') == 0
    
    [answer] = DirectoryDlg(app);
    
    % Handle response
    switch answer
        case 'Select Directory'
            selpath = uigetdir;
            setpref(app.PrefName,'FileDirectory',selpath)
            
    end
    FileDirectoryCheck()
    
elseif length(getpref(app.PrefName,'FileDirectory')) <= 1
    [answer] = DirectoryDlg(app);
    
    % Handle response
    switch answer
        case 'Select Directory'
            selpath = uigetdir;
            setpref(app.PrefName,'FileDirectory',selpath)
    end
    FileDirectoryCheck()
    
elseif exist(getpref(app.PrefName,'FileDirectory')) == 0
    [answer] = DirectoryDlg(app);
    
    
    % Handle response
    switch answer
        case 'Select Directory'
            selpath = uigetdir;
            setpref(app.PrefName,'FileDirectory',selpath)
    end
    FileDirectoryCheck()
end

end

function [answer] = DirectoryDlg(app)
answer = uiconfirm(app.QbPASS_UI,{'A folder containing your database files has not been found.', newline,'Select a folder where your database files are located or where you would like them saved'}, ...
    'Specify Directory','Options',{'Select Directory'},'Icon','warning');
end