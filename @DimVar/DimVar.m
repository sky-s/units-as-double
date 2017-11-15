classdef DimVar < double
    properties
        exponents
    end
    
    methods
        %% Construction, referencing, and assignment.
        function v = DimVar(val,expos)
            v@double(val);
            v.exponents = expos;
        end
        function sref = subsref(o,s)
            sref = DimVar(subsref(double(o),s),o.exponents);
        end
        function o = subsasgn(o,s,b)
            if strcmp(s.type,'()')
                if ~isa(b,'DimVar') && (isempty(b) || all(isnan(b(:))))
                    b = DimVar(b,o.exponents);
                end
                compatibilitycheck(o,b);
                v = double(o);
                newd = subsasgn(v,s,double(b));
                o = DimVar(newd,o.exponents);
            else
                [~] = subsasgn(double(o),s,b); % Throw appropriate error.
                error('Not a supported indexing expression.') % Safety catch.
            end
        end
        function v = colon(v,varargin)
            compatibilitycheck(v,varargin{:});
            v = DimVar(builtin('colon',v,varargin{:}),v.exponents);
        end
        
        %% Concatenation
        function v = cat(dim,v,varargin)
            
            if ~isa(v,'DimVar')
                
                ME = MException('DimVar:incompatibleUnits',...
                    'Incompatible units. All inputs must be DimVar.');
                throwAsCaller(ME);
                
            end
            
            vExpos = v.exponents;
            v = double(v);
            for i = 1:numel(varargin)
                vi = varargin{i};
                if ~isa(vi,'DimVar') || ~isequal(vExpos,vi.exponents)
                    
                    ME = MException('DimVar:incompatibleUnits',...
                        ['Incompatible units. Cannot perform operation on '...
                        'variables with different units.']);
                    throwAsCaller(ME);
                    
                end
                v = cat(dim,v,double(vi));
            end
            v = DimVar(v,vExpos);

            % Functionality of compatibilitycheck method is integrated for the
            % sake of speed.

        end
        function vOut = horzcat(varargin)
            vOut = cat(2,varargin{:});
        end
        function vOut = vertcat(varargin)
            vOut = cat(1,varargin{:});
        end
        
        
        %% Math utilities
        function compatibilitycheck(v, varargin)
            if ~isa(v,'DimVar')
                
                ME = MException('DimVar:incompatibleUnits',...
                    'Incompatible units. All inputs must be DimVar.');
                throwAsCaller(ME);
                
            end
            
            vExpos = v.exponents;
            
            for i = 1:numel(varargin)
                
                if ~isa(varargin{i},'DimVar') || ...
                        ~isequal(vExpos,varargin{i}.exponents)
                    
                    ME = MException('DimVar:incompatibleUnits',...
                        ['Incompatible units. Cannot perform operation on '...
                        'variables with different units.']);
                    throwAsCaller(ME);
                    
                end
            end
        end
        
        %% Math that needs unit checks or cancelation.
        function val = times(v1,v2)
            val = double(v1) .* double(v2);
            if ~isa(v2,'DimVar') % v1 is the DimVar.
                val = DimVar(val,v1.exponents);
            elseif ~isa(v1,'DimVar') % v2 is the DimVar.
                val = DimVar(val,v2.exponents);
            else % BOTH v1 and v2 are DimVar.
                expos = v1.exponents + v2.exponents;
                if any(round(1e5*expos))
                    val = DimVar(val,expos);
                end
            end
        end
        function val = mtimes(v1,v2)
            val = double(v1) * double(v2);
            if ~isa(v2,'DimVar') % v1 is the DimVar.
                val = DimVar(val,v1.exponents);
            elseif ~isa(v1,'DimVar') % v2 is the DimVar.
                val = DimVar(val,v2.exponents);
            else % BOTH v1 and v2 are DimVar.
                expos = v1.exponents + v2.exponents;
                if any(round(1e5*expos))
                    val = DimVar(val,expos);
                end
            end
        end
        
        function val = cumtrapz(v1,v2,varargin)
            val = cumtrapz(double(v1),double(v2),varargin{:});
            if ~isa(v2,'DimVar') % v1 is the DimVar.
                val = DimVar(val,v1.exponents);
            elseif ~isa(v1,'DimVar') % v2 is the DimVar.
                val = DimVar(val,v2.exponents);
            else % BOTH v1 and v2 are DimVar.
                expos = v1.exponents + v2.exponents;
                if any(round(1e5*expos))
                    val = DimVar(val,expos);
                end
            end
        end
        
        function val = mrdivide(v1,v2)
            val = double(v1) / double(v2);
            if ~isa(v2,'DimVar') % v1 is the DimVar.
                val = DimVar(val,v1.exponents);
            elseif ~isa(v1,'DimVar') % v2 is the DimVar.
                val = DimVar(val,-v2.exponents);
            else % BOTH v1 and v2 are DimVar.
                expos = v1.exponents - v2.exponents;
                if any(round(1e5*expos))
                    val = DimVar(val,expos);
                end
            end
        end
        function val = rdivide(v1,v2)
            val = double(v1) ./ double(v2);
            if ~isa(v2,'DimVar') % v1 is the DimVar.
                val = DimVar(val,v1.exponents);
            elseif ~isa(v1,'DimVar') % v2 is the DimVar.
                val = DimVar(val,-v2.exponents);
            else % BOTH v1 and v2 are DimVar.
                expos = v1.exponents - v2.exponents;
                if any(round(1e5*expos))
                    val = DimVar(val,expos);
                end
            end
        end
        function val = ldivide(v1,v2)
            val = double(v1) .\ double(v2);
            if ~isa(v2,'DimVar') % v1 is the DimVar.
                val = DimVar(val,-v1.exponents);
            elseif ~isa(v1,'DimVar') % v2 is the DimVar.
                val = DimVar(val,v2.exponents);
            else % BOTH v1 and v2 are DimVar.
                expos = v2.exponents - v1.exponents;
                if any(round(1e5*expos))
                    val = DimVar(val,expos);
                end
            end
        end
        function val = lmdivide(v1,v2)
            val = double(v1) \ double(v2);
            if ~isa(v2,'DimVar') % v1 is the DimVar.
                val = DimVar(val,-v1.exponents);
            elseif ~isa(v1,'DimVar') % v2 is the DimVar.
                val = DimVar(val,v2.exponents);
            else % BOTH v1 and v2 are DimVar.
                expos = v2.exponents - v1.exponents;
                if any(round(1e5*expos))
                    val = DimVar(val,expos);
                end
            end
        end
        
        function val = mpower(v,y)
            if isa(y,'DimVar')
                error('Exponent may not be a DimVar.');
            else
                val = double(v)^y;
                expos = y*v.exponents;
                
                if any(round(1e5*expos))
                    val = DimVar(val,expos);
                end
            end
        end
        function val = power(v,y)
            if isa(y,'DimVar')
                error('For Z = X.^Y, Y may not be a DimVar.')
            end
            val = double(v).^y;
            expos = y.*v.exponents;
            
            if y
                val = DimVar(val,expos);
            end
        end
        function vOut = sqrt(v)
            vOut = v.^0.5;
        end
        
        function out = atan2(v1,v2)
            compatibilitycheck(v1,v2);
            out = atan2(double(v1),double(v2));
        end
        
        %% Min and max.
        function [varargout] = max(v,varargin)
            if nargin >= 2 && isa(varargin{1},'DimVar')
                compatibilitycheck(v,varargin{1})
            end
            [val,varargout{2:nargout}] = builtin('max',v,varargin{:});
            varargout{1} = DimVar(val,v.exponents);
        end
        function [varargout] = min(v,varargin)
            if nargin >= 2 && isa(varargin{1},'DimVar')
                compatibilitycheck(v,varargin{1})
            end
            [val,varargout{2:nargout}] = builtin('min',v,varargin{:});
            varargout{1} = DimVar(val,v.exponents);
        end
        
        %% Operators only on value.
        function v = abs(v)
            v = DimVar(abs(double(v)),v.exponents);
        end
        function v = conj(v)
            v = DimVar(conj(double(v)),v.exponents);
        end
        function v = ctranspose(v)
            v = DimVar(double(v)',v.exponents);
        end
        function v = cumsum(v,varargin)
            v = DimVar(builtin('cumsum',v,varargin{:}),v.exponents);
        end
        function v = diag(v,varargin)
            v = DimVar(builtin('diag',v,varargin{:}),v.exponents);
        end
        function v = diff(v,varargin)
            v = DimVar(builtin('diff',v,varargin{:}),v.exponents);
        end
        function v = full(v)
            v = DimVar(full(double(v)),v.exponents);
        end
        function v = imag(v)
            v = DimVar(imag(double(v)),v.exponents);
        end
        function v = mean(v,varargin)
            v = DimVar(builtin('mean',v,varargin{:}),v.exponents);
        end
        function v = median(v,varargin)
            v = DimVar(builtin('median',v,varargin{:}),v.exponents);
        end
        function vOut = minus(v1,v2)
            compatibilitycheck(v1,v2);
            vOut = DimVar(double(v1) - double(v2),v1.exponents);
        end
        function v = norm(v,varargin)
            v = DimVar(builtin('norm',v,varargin{:}),v.exponents);
        end
        function v = permute(v,varargin)
            v = DimVar(builtin('permute',v,varargin{:}),v.exponents);
        end
        function vOut = plus(v1,v2)
            compatibilitycheck(v1,v2);
            vOut = DimVar(double(v1) + double(v2),v1.exponents);
        end
        function v = real(v)
            v = DimVar(real(double(v)),v.exponents);
        end
        function v = reshape(v,varargin)
            v = DimVar(builtin('reshape',v,varargin{:}),v.exponents);
        end
        function v = round(v,varargin)
            warning('DimVar:round',...
                'Unexpected results likely when using round.')
            v = DimVar(round(double(v),varargin{:}),v.exponents);
        end
        function v = sort(v,varargin)
            v = DimVar(builtin('sort',v,varargin{:}),v.exponents);
        end
        function v = std(v,varargin)
            v = DimVar(std(double(v),varargin{:}),v.exponents);
        end
        function v = sum(v,varargin)
            v = DimVar(builtin('sum',v,varargin{:}),v.exponents);
        end
        function v = transpose(v)
            v = DimVar(double(v).',v.exponents);
        end
        function v = uminus(v)
            v = DimVar(-double(v),v.exponents);
        end
        function v = uplus(v)
        end
        
        %% Logical
        function tf = eq(v1,v2)
            compatibilitycheck(v1,v2)
            tf = double(v1) == double(v2);
        end
        function tf = ge(v1,v2)
            compatibilitycheck(v1,v2)
            tf = double(v1) >= double(v2);
        end
        function tf = gt(v1,v2)
            compatibilitycheck(v1,v2)
            tf = double(v1) > double(v2);
        end
        function tf = le(v1,v2)
            compatibilitycheck(v1,v2)
            tf = double(v1) <= double(v2);
        end
        function tf = lt(v1,v2)
            compatibilitycheck(v1,v2)
            tf = double(v1) < double(v2);
        end
        function tf = ne(v1,v2)
            compatibilitycheck(v1,v2)
            tf = double(v1) ~= double(v2);
        end
        
        function tf = isequal(varargin)
            tf = iscompatible(varargin{:}) && builtin('isequal',varargin{:});
        end
        
        %% Validators (mustBe...)
        function mustBeGreaterThan(v1,v2)
            compatibilitycheck(v1,v2)
            mustBeGreaterThan(double(v1),double(v2))
        end
        function mustBeGreaterThanOrEqual(v1,v2)
            compatibilitycheck(v1,v2)
            mustBeGreaterThanOrEqual(double(v1),double(v2))
        end
        function mustBeLessThan(v1,v2)
            compatibilitycheck(v1,v2)
            mustBeLessThan(double(v1),double(v2))
        end
        function mustBeLessThanOrEqual(v1,v2)
            compatibilitycheck(v1,v2)
            mustBeLessThanOrEqual(double(v1),double(v2))
        end
        function mustBeNegative(v)
            mustBeNegative(double(v))
        end
        function mustBeNonnegative(v)
            mustBeNonnegative(double(v))
        end
        function mustBeNonpositive(v)
            mustBeNonpositive(double(v))
        end
        function mustBeNonzero(v)
            mustBeNonzero(double(v))
        end
        function mustBePositive(v)
            mustBePositive(double(v))
        end
        
        function validateattributes(v,classes,varargin)
            % Check to make sure that DimVar was specified as an okay input.
            if any(strcmp('DimVar',classes))
                % DimVar okay. Value should be double, so allow it.
                classes = strrep(classes,'DimVar','double');
                validateattributes(double(v),classes,varargin{:})
            else
                builtin('validateattributes',v,classes,varargin{:})
            end
        end
        %% Plotting
        % TODO: histogram; patch; line; plot; plot3; surf
    end
end