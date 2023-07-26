function [Vt, Bckgrd] = removeSignalOutliers(Vt, Bckgrd)


Vt.Steps = numel(Vt.Raw);
Vt.Outliers = Vt.Raw == 0;

Bckgrd.testOutliers = flipud(Bckgrd.Raw);
Bckgrd.Outliers(Vt.Steps) = false;
for ii = 2:Vt.Steps-1
    compValue = Bckgrd.testOutliers(ii);
    testValue = Bckgrd.testOutliers(ii+1);

    if compValue < testValue
        Bckgrd.Outliers(ii+1) = true;
    else
        Bckgrd.Outliers(ii+1) = false;
    end
end



Outliers = or(Vt.Outliers(:), flipud(Bckgrd.Outliers(:)));

Vt.Raw = Vt.Raw(~Outliers);
Bckgrd.Raw = Bckgrd.Raw(~Outliers);

end