function [Vt, Bckgrd] = ObtainSetpoints(Vt, Bckgrd)

setpointNo = round((Vt.Steps/4),0);
%% set point 1
Bckgrd.MinReg = robustfit(log10(Vt.Raw(1:setpointNo)), log10(Bckgrd.Raw(1:setpointNo)));
Bckgrd.MaxReg = robustfit(log10(Vt.Raw(end-(setpointNo-1):end)), log10(Bckgrd.Raw(end-(setpointNo-1):end)));

Vt.Spline = log10([100:600]);
Bckgrd.MinExtrp = (Bckgrd.MinReg(2).*Vt.Spline)+Bckgrd.MinReg(1);
Bckgrd.MaxExtrp = (Bckgrd.MaxReg(2).*Vt.Spline)+Bckgrd.MaxReg(1);

Vt.Setpoint(1) = round(10^(LineIntersect(Vt.Spline([1 end]),  Bckgrd.MinExtrp([1 end]), Vt.Spline([1 end]),  Bckgrd.MaxExtrp([1 end]))),0);

%% set point 2
Bckgrd.Spline = spline(log10(Vt.Raw),log10(Bckgrd.Raw),Vt.Spline);
Bckgrd.diff = ((Bckgrd.MaxExtrp) ./ (Bckgrd.Spline)).*100;

Slope.Raw = diff(Bckgrd.Raw)./diff(Vt.Raw);
Slope.Spline = diff(Bckgrd.Spline)./diff(Vt.Spline);
Slope.Vt = 10.^(Vt.Spline(2:end)-diff(Vt.Spline)./2);
Slope.Selection = Slope.Vt > Vt.Setpoint(1) & Slope.Vt < max(Vt.Raw);
Slope.SlopeDiff = Slope.Spline- (Bckgrd.MaxReg(2)*0.75);
% Vt.Setpoint(2) = round(spline(Bckgrd.diff, 10.^Vt.Spline, 95),0);

Vt.Setpoint(2) = round(interp1( Slope.SlopeDiff(Slope.Selection), Slope.Vt(Slope.Selection),0,'spline'),0);
if Vt.Setpoint(2) < Vt.Setpoint(1)
    SetPointSD = interp1(Vt.Raw, Bckgrd.Raw, Vt.Setpoint(1));
    Vt.Setpoint(2) = round(interp1(Bckgrd.Raw, Vt.Raw,  SetPointSD*2),0);
end

end