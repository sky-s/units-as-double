function [tf,ME] = iscompatible(varargin)
% iscompatible(v1, v2, ...) returns TRUE if all inputs are doubles or Values
% with the same units and FALSE otherwise.
%
%   See also u, compatibilitycheck, isequal.

%
%% Test for Value compatibility.
try 
    compatibilitycheck(varargin{:});
    tf = true;
catch ME
    % Capture all-double case.
    if all(cellfun('isclass',varargin,'double'))
        tf = true;
        return
    end

    if strcmp(ME.identifier,'DimVar:incompatibleUnits')
        tf = false;
    else
        rethrow(ME)
    end

end