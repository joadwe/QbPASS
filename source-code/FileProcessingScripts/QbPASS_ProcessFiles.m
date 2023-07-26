function [app, Dataset, d, var] = QbPASS_ProcessFiles(app, Filenames)
% progress bar

d = uiprogressdlg(app.QbPASS_UI,'Title','Please Wait',...
    'Message',['Importing fcs file data (',num2str(1),'/',num2str(numel(Filenames)),')']);

for i = 1:numel(Filenames)

    % read fcs
    [fcsdata, fcshdr] = QbPASS_fcs_read(Filenames{i});

    if numel(strfind(Filenames{i},'$')) == 4
        InputLocator = strfind(Filenames{i},'$');

        Test_Condition{i} = Filenames{i}(InputLocator(1)+1:InputLocator(2)-1); % get test condition of .fcs data
        Laser_State{i} = Filenames{i}(InputLocator(2)+1:InputLocator(3)-1); % get laser status of .fcs data
        Pulser_Intensity{i} = Filenames{i}(InputLocator(3)+1:InputLocator(4)-1); % get pulser intensity of .fcs data
        Voltage(i) = str2double(Filenames{i}(InputLocator(4)+1:end-4)); % get voltage of .fcs data

    else

        % check keywords exist in the fcs file
        Keywords = {'Voltage','LaserStatus','TestCondition','PulserIntensity'};
        for ie = 1:numel(Keywords)
            error(ie) = isfield(fcshdr, Keywords{ie});
        end

        % give error message if keyword doesnt exist
        if min(error) == 0
            errorstr = [fcshdr.Filename, ' does not contain the following keywords:  ', (Keywords(not(error)))];
            uialert(app.QbPASS_UI, errorstr, 'Error reading keywords');
            return
        else
            Voltage(i) = fcshdr.(Keywords{1}); % get voltage of .fcs data
            Laser_State{i} = fcshdr.(Keywords{2}); % get laser status of .fcs data
            Test_Condition{i} = fcshdr.(Keywords{3}); % get test condition of .fcs data
            Pulser_Intensity{i} = num2str(fcshdr.(Keywords{4})); % get pulser intensity of .fcs data
        end
    end

    % convert to common criteria
    if strcmp(Test_Condition{i},'0')
        Test_Condition{i} = 'B';
    elseif strcmp(Test_Condition{i},'1')
        Test_Condition{i} = 'L';
    end

    P_name = repmat({'P'}, fcshdr.PAR, 1); % parameter
    N_name = repmat({'N'}, fcshdr.PAR, 1); % parameter name
    V_name = repmat({'V'}, fcshdr.PAR, 1); % parameter voltage
    R_name = repmat({'R'}, fcshdr.PAR, 1); % parameter range

    Par_no = strsplit(num2str(1:fcshdr.PAR));
    Par_vt = strcat(P_name(:), Par_no(:), V_name(:));
    Par_N = strcat(P_name(:), Par_no(:), N_name(:));
    Par_R = strcat(P_name(:), Par_no(:), R_name(:));


    for ii = 1:fcshdr.PAR
        if isfield(fcshdr,(Par_N{ii}))

            ParNames{i,ii} = fcshdr.(Par_N{ii});    % get parameter names
            ParInd(i,ii)  = ii;                     % get index for parameter
            ParVt(i,ii) = Voltage(i);               % get voltages
            Range{i,ii} = fcshdr.(Par_R{ii});       % get dynamic ranges

            Stat_Mean(i,ii) = mean(fcsdata(:,ii));               % get statistics for each of the parameters
            Stat_Median(i,ii) = median(fcsdata(:,ii));               % get statistics for each of the parameters
            Stat_SD(i,ii) = std(fcsdata(:,ii));                      % standard deviation
            Stat_CV(i,ii) = std(fcsdata(:,ii))./mean(fcsdata(:,ii)); % CV
            Stat_Pct(i,ii) = prctile(fcsdata(:,ii),68);   % 95th prctile

            tempDataa = rmoutliers(fcsdata(:,ii),'median');
            roStat_Mean(i,ii) = mean(tempDataa);               % get statistics for each of the parameters
            roStat_Median(i,ii) = median(tempDataa);               % get statistics for each of the parameters
            roStat_SD(i,ii) = std(tempDataa);                      % standard deviation
            roStat_CV(i,ii) = roStat_SD(i,ii)./roStat_Mean(i,ii); % CV
            roStat_Pct(i,ii) = prctile(tempDataa,68);   % 95th prctile


        end

        % get voltage of fcs file
        if isfield(fcshdr,(Par_vt{ii}))
            ParVt(i,ii) = fcshdr.(Par_vt{ii});
        end

    end

    if isfield(fcshdr,'DATE') == 1
        Date(i) = datetime(fcshdr.DATE);
    end
    if isfield(fcshdr,'CYT') == 1
        Cyt{i} = fcshdr.CYT;
    end

    % progress bar update
    if rem(i,25) == 0
        d.Value = i/numel(Filenames);
        d.Message = ['Importing fcs file data (',num2str(i),'/',num2str(numel(Filenames)),')'];
    end
end

d.Message = ['Parsing fcs file data'];
d.Indeterminate = 'on';

% create database timestamp
if isempty(Date)
    unqDate = datetime('now', 'Format','dd-MMM-yyyy');
else
    unqDate = unique(Date);
end
var = ['D_', num2str(datenum(unqDate(1)))];

% database
Dataset.(var).ID = app.SelectedCytometerDropDown.Value;
Dataset.(var).Cyt = unique(Cyt);
Dataset.(var).AcqDate = unique(Date);
Dataset.(var).Range = Range;
Dataset.(var).ParNames = ParNames;
Dataset.(var).SD = Stat_SD;
Dataset.(var).CV = Stat_CV;
Dataset.(var).Pct = Stat_Pct;
Dataset.(var).Med = Stat_Median;
Dataset.(var).Mean = Stat_Mean;
Dataset.(var).roSD = roStat_SD;
Dataset.(var).roCV = roStat_CV;
Dataset.(var).roPct = roStat_Pct;
Dataset.(var).roMed = roStat_Median;
Dataset.(var).roMean = roStat_Mean;
Dataset.(var).Vt = ParVt;
Dataset.(var).LaserState = Laser_State;
Dataset.(var).TestCond = Test_Condition;
Dataset.(var).PulserInt = Pulser_Intensity;
Dataset.(var).Voltage = Voltage;
Dataset.(var).fcsdir = app.ImportSelpath;
Dataset.(var).phiThresh = getpref(app.PrefName,'Phi_Threshold');
Dataset.(var).fcshdr = fcshdr;

% create working database for splitting
Dataset.(var).Conds =  strcat(Laser_State,Test_Condition); % get conditions per file
Dataset.(var).CondsUq = unique(Dataset.(var).Conds); % get unique conditions per file
fieldL = {'Mean','Med','SD','CV','Vt','Pct','roMean','roMed','roSD','roCV','roPct'};

P = replace(Dataset.(var).PulserInt,'-','N');

for i = 1:numel(Dataset.(var).CondsUq)
    CondIdx = find(strcmp(Dataset.(var).Conds, Dataset.(var).CondsUq{i}));
    TempVt = Dataset.(var).Vt(CondIdx,:);
    Cond = ['Cond_',Dataset.(var).CondsUq{i}];
    for ii = 1:size(TempVt,2)
        Dataset.(var).Set.(Cond).VtUq{ii} = unique(TempVt(:,ii));
    end
end


for i = 1:size(Dataset.(var).Med,1)
    CondIdx = find(strcmp(Dataset.(var).Conds{i}, Dataset.(var).CondsUq));
    for ii = 1:size(Dataset.(var).Med,2)
        ParField = replace(Dataset.(var).ParNames{i,ii},'-','_');
        PIntField = ['P',P{i}];
        VtField = ['V',num2str(Dataset.(var).Vt(i,ii))];
        Cond = ['Cond_',Dataset.(var).Conds{i}];
        RowInd = find(Dataset.(var).Vt(i,ii) == Dataset.(var).Set.(Cond).VtUq{ii});
        for f = 1:numel(fieldL)
            MetricField = (fieldL{f});
            Dataset.(var).Set.(Cond).(PIntField).(MetricField)(RowInd,ii) = Dataset.(var).(fieldL{f})(i,ii);
        end
    end
end

Selected_Cond = 'Cond_1L';
Fields = fields(Dataset.(var).Set.(Selected_Cond));
PulserInt = natsort(Fields(contains(fields(Dataset.(var).Set.Cond_1L),'P')));
Dataset.(var).Set.(Selected_Cond).PulseIntFields = PulserInt;
Dataset.(var).Set.(Selected_Cond).PulserInt = str2double(replace(replace(PulserInt,'P',''),'N','-'));

ParInd = not(contains(Dataset.(var).ParNames(1,:), ["FSC","SSC","Time","-H"]));
ParNams = Dataset.(var).ParNames(1,ParInd);
Target = getpref(app.PrefName,'Target');

UnqParNames = unique(Dataset.(var).ParNames, 'stable')';
ParInd = not(contains(UnqParNames(1,:), (getpref(app.PrefName,'ExclusionParameters'))));
RangeArray = cell2mat(Dataset.(var).Range(:,ParInd)); % remove FS,SS,Time from dynamic ranges

UniqRanges = unique(RangeArray(:)); % find unique ranges
if numel(UniqRanges) == 1
    Dataset.(var).DyRange = UniqRanges;
else
    uialert(app.QbPASS_UI,'Inconsisent instrument .fcs files detected','Error finding dynamic range')
end

d = uiprogressdlg(app.QbPASS_UI,'Title','Please Wait',...
    'Message','Processing file data','Indeterminate','on');

end