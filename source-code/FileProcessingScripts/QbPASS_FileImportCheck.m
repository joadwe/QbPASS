function [Files]=QbPASS_FileImportCheck(app,Files)

keywordpz = strfind({Files.name},'$');
keywordsz = cellfun(@numel, keywordpz);

if sum(keywordsz==3) ~=0
    Ramping_Files = Files(keywordsz==3);
    Ramping_Files_keywords = keywordpz(keywordsz==3);

    for i = 1:numel(Ramping_Files_keywords)
        temp = Ramping_Files(i).name;
        ramp_range = temp(Ramping_Files_keywords{i}(2)+1:Ramping_Files_keywords{i}(3)-1);
        gaps = strfind(ramp_range,'_');

        Pulser_min(i) = str2double(ramp_range(1:gaps(1)-1));
        Pulser_max(i) = str2double(ramp_range(gaps(1)+1:gaps(2)-1));
        Pulser_inc(i) = str2double(ramp_range(gaps(2)+1:end));
        Voltage(i) = str2double(temp(Ramping_Files_keywords{i}(3)+1:end-4));
    end

    if numel(unique(Pulser_min)) == 1 & numel(unique(Pulser_max)) == 1 & numel(unique(Pulser_inc)) == 1
        Ramping_File_Conversion(app,Ramping_Files);
        Files = dir([Files(1).folder,'/*.fcs']);
    else
        uialert(app.QbPASS_UI,'LED pulser ramping has inconsistent criteria','Import error');
    end

end


end