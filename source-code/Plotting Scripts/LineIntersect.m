function [xi,yi] = LineIntersect(L1x, L1y, L2x, L2y)

x1 = L1x(1);
y1 = L1y(1);
x2 = L1x(2);
y2 = L1y(2);
x3 = L2x(1);
y3 = L2y(1);
x4 = L2x(2);
y4 = L2y(2);
%------------------------------------------------------------------------------------------------------------------------
% Line segments intersect parameters
u = ((x1-x3)*(y1-y2) - (y1-y3)*(x1-x2)) / ((x1-x2)*(y3-y4)-(y1-y2)*(x3-x4));
t = ((x1-x3)*(y3-y4) - (y1-y3)*(x3-x4)) / ((x1-x2)*(y3-y4)-(y1-y2)*(x3-x4));
%------------------------------------------------------------------------------------------------------------------------
% Check if intersection exists, if so then store the value
if (u >= 0 && u <= 1.0) && (t >= 0 && t <= 1.0)
    xi = ((x3 + u * (x4-x3)) + (x1 + t * (x2-x1))) / 2;
    yi = ((y3 + u * (y4-y3)) + (y1 + t * (y2-y1))) / 2;
else
    xi = NaN;
    yi = NaN;
end


end