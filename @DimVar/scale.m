function v = scale(v, sf)
%  SCALE(input, scaleFactor) performs a dynamic scaling operation by the
%  scale factor on the input variable.
% 
%   To learn about dynamic scaling:
%   https://www.google.com/search?q=dynamic+scaling+aircraft
% 
%   See also UNITS.

a = 0*v.exponents;
a(1:3) = [1 3 0.5];

v = v .* sf.^sum(v.exponents.*a);