function [numString, denString, v, val, appendStr] = displayparser(v)
numString = '';
denString = '';
val = double(v);

for nd = 1:numel(u.baseNames)
    currentExp = v.exponents(nd);
    [n,d] = rat(currentExp);
    if currentExp > 0 % Numerator
        if d == 1
            switch currentExp
                case 1
                    numString = sprintf('%s[%s]',numString,u.baseNames(nd));
                case 2
                    numString = sprintf('%s[%s²]',numString,u.baseNames(nd));
                case 3
                    numString = sprintf('%s[%s³]',numString,u.baseNames(nd));
                otherwise
                    numString = sprintf('%s[%s^%g]',...
                        numString,u.baseNames(nd),currentExp);
            end
        else
            numString = sprintf('%s[%s^(%g/%g)]',...
                numString,u.baseNames(nd),n,d);
        end
    elseif currentExp < 0 %Denominator
        if d == 1 
            switch currentExp
                case -1
                    denString = sprintf('%s[%s]',denString,u.baseNames(nd));
                case -2
                    denString = sprintf('%s[%s²]',denString,u.baseNames(nd));
                case -3
                    denString = sprintf('%s[%s³]',denString,u.baseNames(nd));
                otherwise
                    denString = sprintf('%s[%s^%g]',...
                        denString,u.baseNames(nd),-currentExp);
            end
        else
            denString = sprintf('%s[%s^(%g/%g)]',...
                denString,u.baseNames(nd),-n,d);
        end
    end
end

% Trim brakets for lonely terms.
if 1 == nnz(sign(v.exponents) == 1)
    numString = numString(2:end-1);
end
if 1 == nnz(sign(v.exponents) == -1)
    denString = denString(2:end-1);
end
if isempty(numString)
    numString = '1';
end

% Determine if it matches a preferred unit. Preferred units can be list or
% 2-column cell array.
if isempty(u.displayUnits)
    % Do nothing.
elseif iscellstr(u.displayUnits)
    for i = 1:length(u.displayUnits)
        str = u.displayUnits{i};
        test = v/u.(str);
        if ~isa(test, 'DimVar')
            % Units match.
            numString = str;
            denString = '';
            if nargout > 2
                v = feval(class(v),test,v.exponents);
                val = test;
            end
            break
        end
    end
elseif iscell(u.displayUnits)
    prefStrings = u.displayUnits(:,1);
    prefUnits = u.displayUnits(:,2);
    for i = 1:numel(prefStrings)
        test = v/prefUnits{i};
        if ~isa(test, 'DimVar')
            % Units match.
            numString = prefStrings{i};
            denString = '';
            if nargout > 2
                v = feval(class(v),test,v.exponents);
                val = test;
            end
            break
        end
    end
else
    error('displayUnits must be cellstr or 2-column cell array.')
end

if nargout > 4
    if isempty(denString)
        appendStr = numString;
    else
        appendStr = sprintf('%s/%s', numString, denString);
    end
end