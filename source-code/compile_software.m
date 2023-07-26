clear; clc

% Updates made between versions
ver = '1.0.1.0';
MasterFile = 'master.m';

SoftwareName = 'QbPASS';

path = strsplit((which(MasterFile)),filesep);
EmptyPath = cellfun(@isempty, path);
SourcePath = fullfile(path{~EmptyPath(1:end-1)});
ProjPath = fullfile(path{~EmptyPath(1:end-2)});

% OS spectific
if ismac()
    installDir = ['/Applications/',SoftwareName];
    outputDir = ['/Users/welshjoa/Documents/Compiled/',SoftwareName,'/Mac/',ver];
    Logo_filepath = ['/',fullfile(SourcePath,'Icons','QbLogo.jpg')];
    intallerName = [SoftwareName,'_Installer_Mac'];
    SourcePath = [filesep,SourcePath];
    ProjPath = [filesep,ProjPath];
elseif ispc()
    installDir = ['C:\Program Files\',SoftwareName];
    outputDir = ['C:\Users\welshjoa\Documents\MATLAB\',SoftwareName,'\Compiled\',ver];
    Logo_filepath = ['C:\',fullfile(SourcePath,'Icons','QbLogo.jpg')];
    intallerName = [SoftwareName,'_Installer_PC'];
end

% get non-MATLAB file dependancies
[FileDep] = getFileDependencies(SourcePath);

% remove output directory if exists. Overwrite can cause issues with
% compiling. The recreate the directory.
if isfolder(outputDir)
    rmdir(outputDir,'s')
end
mkdir(outputDir)

% application compiler options
App.opts = compiler.build.StandaloneApplicationOptions(fullfile(SourcePath,MasterFile));
App.opts.EmbedArchive = 'on';
App.opts.ExecutableIcon = Logo_filepath;
App.opts.ExecutableName = SoftwareName;
App.opts.ExecutableSplashScreen =  Logo_filepath;
App.opts.ExecutableVersion = ver;
App.opts.TreatInputsAsNumeric = 'off';
App.opts.AutoDetectDataFiles = 'on';
App.opts.AdditionalFiles = FileDep;
App.opts.Verbose = 'on';
App.opts.OutputDir = fullfile(outputDir,'Application');

% compile standalone application
App.results = compiler.build.standaloneApplication(App.opts);
App.runtimeProducts = fullfile(App.results.Options.OutputDir,'requiredMCRProducts.txt');

% installation compiler options
Inst.opts = compiler.package.InstallerOptions(App.results);
Inst.opts.RuntimeDelivery =  'web';
Inst.opts.InstallerSplash =  Logo_filepath;
Inst.opts.InstallerIcon = Logo_filepath;
Inst.opts.InstallerLogo =  Logo_filepath;
Inst.opts.AuthorName = 'Joshua Welsh';
Inst.opts.AuthorEmail = 'joshua.welsh@nih.gov';
Inst.opts.AuthorCompany = 'U.S. National Institutes of Health';
Inst.opts.Summary = 'Software for the acquisition, calibration and analysis of Spectradyne nCS1 data.';
Inst.opts.Description = '';
Inst.opts.InstallationNotes = '';
Inst.opts.Shortcut = '';
Inst.opts.Version = ver;
Inst.opts.InstallerName = intallerName;
Inst.opts.ApplicationName = SoftwareName;
Inst.opts.OutputDir = fullfile(outputDir,'Installer');
Inst.opts.DefaultInstallationDir = installDir;

Files = [App.results.Files(:)];

% create installation compiler
compiler.package.installer(Files,App.runtimeProducts,'Options',Inst.opts);

function [FileDep] = getFileDependencies(SourcePath)

files = dir(fullfile(SourcePath,'HTML','**'));
FileDep = [];
for i = 1:size(files,1)
    rmInd = strcmp(files(i).name,{'.','..','.DS_Store'});
    if sum(rmInd) == 0
        FileDep = [FileDep; string(fullfile(files(i).folder, files(i).name))];
    end
end

end

