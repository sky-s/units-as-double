function d = u2duration(v)
% u2duration  Convert DimVar time to duration data type.
%   u2duration inspects for a pure time dimension and then runs seconds on the
%   input.
%   
%   If you have redefined the base time dimension name, use caution.
% 
%   See also duration, seconds, units, u2num.

if isa(v/u.s,'DimVar')
    error('A pure time DimVar (with exponent of one) is required.')
else
    d = seconds(v);
end