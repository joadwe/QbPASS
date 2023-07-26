function Ramping_File_Conversion(app,files)


% create time stamp for output folders
timestamp = datestr(datetime('now'));
timestamp = replace(timestamp, ':','-');

dir = files(1).folder;
export_dirPass = fullfile(dir, [timestamp, ' Original'],'Pass');
export_dirFail = fullfile(dir, [timestamp, ' Original'],'Fail');
export_dirGate = fullfile(dir, [timestamp, ' Original'],'Gating');

mkdir(export_dirPass)
mkdir(export_dirFail)
mkdir(export_dirGate)

count = 0;
d = uiprogressdlg(app.QbPASS_UI,'Title','Please Wait',...
    'Message',['Converting pulser ramping fcs file data (',num2str(1),'/',num2str(size(files,1)),')']);

for i = 1:size(files,1)

    [dat, hdr] = fcs_read(fullfile(files(i).folder, files(i).name));

    name = files(i).name;

    [Laser_State, Int, Voltage] = getFileInfo(name);

    TimeInd = contains({hdr.Parameters.Name},'Time');
    TimeData = dat(:,TimeInd);
    diffs = TimeData(2:end)- TimeData(1:end-1);

    Ind = find(diffs > 30);

    ParNames = {hdr.Parameters.Name};
    ParInd = contains(ParNames,{'FSC','SSC','Time','-H'});
    ParNames = ParNames(~ParInd);

    res=512;
    xBins = linspace(min(TimeData),max(TimeData), res);

    plotDat = dat(:,~ParInd);

    fig = figure('units','normalized','position',[0 0 1 1],'visible','off');
    t = tiledlayout('flow','tilespacing','compact','padding','compact');
    colormap turbo
    for ii = 1:numel(ParNames)
        nexttile
        yBins = logspace(0,ceil(log10(max(plotDat(:,ii)))),res);
        xData = TimeData;
        yData = plotDat(:,ii);
        histogram2(xData(:),yData(:),'XBinEdges',xBins,'YBinEdges',yBins,'DisplayStyle','tile')
        %         scatter(xData,yData,'.k')
        set(gca,'yscale','log','box','on','linewidth',2,'fontsize',14)
        xlabel('Time')
        ylabel(ParNames{ii})
        for iii = 1:numel(Ind)
            line([xData(Ind(iii)) xData(Ind(iii))],[min(yBins) max(yBins)],'color','r','linewidth',2,'linestyle',':')
        end
        yticks(10.^unique(round(log10(yBins),0)))
        xlim([0 max(TimeData)])
    end
    exportgraphics(fig, fullfile(export_dirGate, replace(files(i).name,'.fcs','.pdf')))
    close(fig)

    if numel(Ind) - (numel(Int) + 1) > 0
        movefile(fullfile(files(i).folder,files(i).name), export_dirFail)
    else
        for ii = 1:numel(Ind)
            if ii == numel(Int) + 1
            else
                if ii == 1
                    gdat = dat(Ind(ii):Ind(ii+1),:);
                    writename = ['$B','$',num2str(Laser_State),'$-99','$',num2str(Voltage)];

                    hdr.Voltage = num2str(Voltage);
                    hdr.LaserStatus = Laser_State;
                    hdr.TestCondition = 'Trigger B';
                    if Int(ii) <-94
                        hdr.PulserIntensity = '-99';
                    else
                        hdr.PulserIntensity = num2str(Int(ii));
                    end
                elseif ii == numel(Ind)
                    gdat = dat(Ind(ii):end,:);
                    writename = ['$L','$',num2str(Laser_State),'$',num2str(Int(ii)),'$',num2str(Voltage)];

                    hdr.Voltage = num2str(Voltage);
                    hdr.LaserStatus = Laser_State;
                    hdr.TestCondition = 'LED Pulser';
                    hdr.PulserIntensity = num2str(Int(ii));
                else
                    gdat = dat(Ind(ii):Ind(ii+1)-1,:);
                    writename = ['$L','$',num2str(Laser_State),'$',num2str(Int(ii)),'$',num2str(Voltage)];

                    hdr.Voltage = num2str(Voltage);
                    hdr.LaserStatus = Laser_State;
                    hdr.TestCondition = 'LED Pulser';
                    hdr.PulserIntensity = num2str(Int(ii));
                end
%                 [gdat] = rmoutliers(gdat);

                count = count + 1;
                hdr.TOT = size(gdat, 1);

                fcs_write(dir, [writename,'.fcs'], gdat, hdr)
            end

        end
        movefile(fullfile(files(i).folder,files(i).name), export_dirPass)
    end

    d.Value = i/size(files,1);
    d.Message = ['Converting pulser ramping fcs file data (',num2str(i),'/',num2str(size(files,1)),')'];

end
close(d)
end

function [Laser_State, Int, Voltage] = getFileInfo(name)
InputLocator = strfind(name,'$');

if strcmp(name(InputLocator(1)+1:InputLocator(2)-1),'0')
    Laser_State = '0'; % get laser status of .fcs data
elseif strcmp(name(InputLocator(1)+1:InputLocator(2)-1),'1')
    Laser_State = '1'; % get laser status of .fcs data
elseif strcmp(name(InputLocator(1)+1:InputLocator(2)-1),'B')
    Laser_State = '0'; % get laser status of .fcs data
elseif strcmp(name(InputLocator(1)+1:InputLocator(2)-1),'L')
    Laser_State = '1'; % get laser status of .fcs data

end

Voltage = str2double(name(InputLocator(3)+1:end-4)); % get voltage of .fcs data

temp = name(InputLocator(2)+1:InputLocator(3)-1);
ind = strfind(temp, '_');
Ramp(1) = str2double(temp(1:ind(1)-1));
Ramp(2) = str2double(temp(ind(1)+1:ind(2)-1));
Ramp(3) = str2double(temp(ind(2)+1:end));

if Ramp(3) == 0
    Int = Ramp(1):Ramp(2):Ramp(3);
else
    Int = Ramp(1):Ramp(3):Ramp(2);
end
end
