function [s] = num2str(v, varargin)
[~, ~, ~, val, appendString] = displayparser(v);

s = num2str(val, varargin{:});

if isempty(s)
    s = '[]';
end

s = strcat(s,[' ' appendString]);
