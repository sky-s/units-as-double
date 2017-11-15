classdef DimVar < double
    properties
        exponents
    end
    
    methods
        %% Construction, referencing, and assignment.
        function v = DimVar(val,expos)
            v = v@double(val);
            v.exponents = expos;
        end
        function sref = subsref(o,s)
            sref = feval(class(o),subsref(double(o),s),o.exponents);
        end
        function o = subsasgn(o,s,b)
            if strcmp(s.type,'()')
                if ~isa(b,'DimVar') && (isempty(b) || all(isnan(b(:))))
                    b = DimVar(b,o.exponents);
                end
                bicompatibilitycheck(o,b);
                v = double(o);
                newd = subsasgn(v,s,double(b));
                o = feval(class(o),newd,o.exponents);
            else
                [~] = subsasgn(double(o),s,b); % Throw appropriate error.
                error('Not a supported indexing expression.') % Safety catch.
            end
        end
        function v = colon(v,varargin)
            compatibilitycheck(v,varargin{:});
            v = feval(class(v),builtin('colon',v,varargin{:}),v.exponents);
        end
        
        %% Concatenation
        function vOut = cat(dim,varargin)
            compatibilitycheck(varargin{:});
            
            val = cellfun(@double,varargin,'UniformOutput',false);
            val = cat(dim,val{:});
            vOut = DimVar(val,varargin{1}.exponents);
        end
        function vOut = horzcat(varargin)
            vOut = cat(2,varargin{:});
        end
        function vOut = vertcat(varargin)
            vOut = cat(1,varargin{:});
        end
        
        
        %% Math utilities
        function v = clearcanceledunits(v)
            % Returns appropriate type for operations that can change units.
            % Appropriate type may be Length, Mass, or simple double.
            if ~nnz(round(v.exponents,5))
                v = double(v);
            end
%             expos = round(v.exponents,5);
%             switch nnz(expos)
%                 case 0
%                     v = double(v);
%                 case 1
%                     singles = expos==1;
%                     if any(singles)
%                         switch find(singles)
%                             case 1
%                                 v = Length(double(v),expos);
%                             case 2
%                                 v = Mass(double(v),expos);
%                             case 3
%                                 v = Time(double(v),expos);
%                             case 5
%                                 v = Temperature(double(v),expos);
%                             case 9
%                                 v = Currency(double(v),expos);
%                         end
%                     end
%                     if expos(1) > 1
%                         switch expos(1)
%                             %                             case 1
%                             %                                 vOut = Length(double(v),expos);
%                             case 2
%                                 v = Area(double(v),expos);
%                             case 3
%                                 v = Volume(double(v),expos);
%                         end
%                     end
%                 case 2
%                     if isequal(expos(1:3),[1 0 -1])
%                         v = Velocity(double(v),expos);
%                     end
%                 case 3
%                     if      isequal(expos(1:3),[1 1 -2])
%                         v = Force(double(v),expos);
%                     elseif  isequal(expos(1:3),[2 1 -2])
%                         v = Energy(double(v),expos);
%                     elseif  isequal(expos(1:3),[2 1 -3])
%                         v = Power(double(v),expos);
%                     elseif  isequal(expos(1:3),[-1 1 -2])
%                         v = Pressure(double(v),expos);
%                     end
%             end
        end
        function bicompatibilitycheck(v1, v2)
            % Throws an error if two inputs are not DimVars with the same units.
            % Simpler and faster version of compatibilitycheck.
            %
            %   See also u, iscompatible, compatibilitycheck.
            
            if ~isa(v1,'DimVar') || ~isa(v2,'DimVar') || ~isequal(v1.exponents,v2.exponents)
                ME = MException('DimVar:incompatibleUnits',...
                    ['Incompatible units. Cannot perform operation on '...
                    'variables with different units.']);
                throwAsCaller(ME);
            end
        end
        function compatibilitycheck(varargin)
            % testcompatibility(v1, v2, ...) returns TRUE if all inputs are
            % Values with the same units and throws an error otherwise.
            %
            %   If throwing an error is not desired, use iscompatible.
            %
            %   See also u, iscompatible.
            
            try
                c = cellfun(@(v) round(v.exponents,5),varargin,'UniformOutput',false);
            catch ME
                if any(strcmp(ME.identifier,{'MATLAB:structRefFromNonStruct' ...
                        'MATLAB:noSuchMethodOrField'}))
                    throwAsCaller(MException('DimVar:incompatibleUnits',...
                        ['Incompatible units. Cannot perform operation on '...
                        'variables with different units.']));
                else
                    rethrow(ME)
                end
            end
            
            if nargin == 1 || isequal(c{:})
                % Single input is always compatible with itself.
            else
                ME = MException('Value:incompatibleUnits',...
                    ['Incompatible units. Cannot perform operation on '...
                    'variables with different units.']);
                throwAsCaller(ME);
            end
        end
        
        %% Math that needs unit checks or cancelation.
        function vOut = times(v1,v2)
            val = double(v1) .* double(v2);
            if ~isa(v2,'DimVar') % v1 is the DimVar.
                expos = v1.exponents;
            elseif ~isa(v1,'DimVar') % v2 is the DimVar.
                expos = v2.exponents;
            else % BOTH v1 and v2 are DimVar.
                expos = v1.exponents + v2.exponents;
            end
            vOut = clearcanceledunits(DimVar(val,expos));
        end
        function vOut = mtimes(v1,v2)
            val = double(v1) * double(v2);
            if ~isa(v2,'DimVar') % v1 is the DimVar.
                expos = v1.exponents;
            elseif ~isa(v1,'DimVar') % v2 is the DimVar.
                expos = v2.exponents;
                
                
            else % BOTH v1 and v2 are DimVar.
                expos = v1.exponents + v2.exponents;
            end
            vOut = clearcanceledunits(DimVar(val,expos));
        end
        
        function vOut = cumtrapz(v1,v2,varargin)
            val = cumtrapz(double(v1),double(v2),varargin{:});
            if ~isa(v2,'DimVar') % v1 is the DimVar.
                expos = v1.exponents;
            elseif ~isa(v1,'DimVar') % v2 is the DimVar.
                expos = v2.exponents;
            else % BOTH v1 and v2 are DimVar.
                expos = v1.exponents + v2.exponents;
            end
            vOut = clearcanceledunits(DimVar(val,expos));
        end
        
        
        function vOut = mrdivide(v1,v2)
            val = double(v1) / double(v2);
            if ~isa(v2,'DimVar') % v1 is the DimVar.
                expos = v1.exponents;
            elseif ~isa(v1,'DimVar') % v2 is the DimVar.
                expos = -v2.exponents;
                
            else % BOTH v1 and v2 are DimVar.
                expos = v1.exponents - v2.exponents;
            end
            vOut = clearcanceledunits(DimVar(val,expos));
        end
        function vOut = rdivide(v1,v2)
            val = double(v1) ./ double(v2);
            if ~isa(v2,'DimVar') % v1 is the DimVar.
                expos = v1.exponents;
            elseif ~isa(v1,'DimVar') % v2 is the DimVar.
                expos = -v2.exponents;
                
            else % BOTH v1 and v2 are DimVar.
                expos = v1.exponents - v2.exponents;
            end
            vOut = clearcanceledunits(DimVar(val,expos));
        end
        function vOut = ldivide(v1,v2)
            val = double(v1) .\ double(v2);
            if ~isa(v2,'DimVar') % v1 is the DimVar.
                expos = -v1.exponents;
            elseif ~isa(v1,'DimVar') % v2 is the DimVar.
                expos = v2.exponents;
            else % BOTH v1 and v2 are DimVar.
                expos = v2.exponents - v1.exponents;
            end
            vOut = clearcanceledunits(DimVar(val,expos));
        end
        function vOut = lmdivide(v1,v2)
            val = double(v1) \ double(v2);
            if ~isa(v2,'DimVar') % v1 is the DimVar.
                expos = -v1.exponents;
            elseif ~isa(v1,'DimVar') % v2 is the DimVar.
                expos = v2.exponents;
            else % BOTH v1 and v2 are DimVar.
                expos = v2.exponents - v1.exponents;
            end
            vOut = clearcanceledunits(DimVar(val,expos));
        end
        
        function vOut = plus(v1,v2)
            bicompatibilitycheck(v1,v2);
            
            vOut = DimVar(double(v1) + double(v2),v1.exponents);
%             vOut = feval(class(v1),double(v1) + double(v2),v1.exponents);
        end
        function vOut = minus(v1,v2)
            bicompatibilitycheck(v1,v2);
            
            vOut = feval(class(v1),double(v1) - double(v2),v1.exponents);
        end
        
        function vOut = mpower(v,y)
            if isa(y,'DimVar')
                error('Exponent may not be a DimVar.');
            else
                val = double(v)^y;
                expos = y*v.exponents;
                
                vOut = clearcanceledunits(DimVar(val,expos));
            end
        end
        function vOut = power(v,y)
            if isa(y,'DimVar')
                error('Exponent may not be a DimVar.');
            else
                val = double(v).^y;
                expos = y*v.exponents;
                
                vOut = clearcanceledunits(DimVar(val,expos));
            end
        end
        function vOut = sqrt(v)
            vOut = v.^0.5;
        end
        function out = atan2(v1,v2)
            bicompatibilitycheck(v1,v2);
            out = atan2(double(v1),double(v2));
        end
        
        %% Min and max.
        function [varargout] = max(v,varargin)
            if nargin >= 2 && isa(varargin{1},'DimVar')
                bicompatibilitycheck(v,varargin{1})
            end
            [val,varargout{2:nargout}] = builtin('max',v,varargin{:});
            varargout{1} = feval(class(v),val,v.exponents);
        end
        function [varargout] = min(v,varargin)
            if nargin >= 2 && isa(varargin{1},'DimVar')
                bicompatibilitycheck(v,varargin{1})
            end
            [val,varargout{2:nargout}] = builtin('min',v,varargin{:});
            varargout{1} = feval(class(v),val,v.exponents);
        end
        
        %% Operators only on value.
        function v = abs(v)
            v = feval(class(v),abs(double(v)),v.exponents);
        end
        function v = conj(v)
            v = feval(class(v),conj(double(v)),v.exponents);
        end
        function v = ctranspose(v)
            v = feval(class(v),double(v)',v.exponents);
        end
        function v = cumsum(v,varargin)
            v = feval(class(v),builtin('cumsum',v,varargin{:}),v.exponents);
        end
        function v = diag(v,varargin)
            v = feval(class(v),builtin('diag',v,varargin{:}),v.exponents);
        end
        function v = diff(v,varargin)
            v = feval(class(v),builtin('diff',v,varargin{:}),v.exponents);
        end
        function v = full(v)
            v = feval(class(v),full(double(v)),v.exponents);
        end
        function v = imag(v)
            v = feval(class(v),imag(double(v)),v.exponents);
        end
        function v = mean(v,varargin)
            v = feval(class(v),builtin('mean',v,varargin{:}),v.exponents);
        end
        function v = median(v,varargin)
            v = feval(class(v),builtin('median',v,varargin{:}),v.exponents);
        end
        function v = norm(v,varargin)
            v = feval(class(v),builtin('norm',v,varargin{:}),v.exponents);
        end
        function v = permute(v,varargin)
            v = feval(class(v),builtin('permute',v,varargin{:}),v.exponents);
        end
        function v = real(v)
            v = feval(class(v),real(double(v)),v.exponents);
        end
        function v = reshape(v,varargin)
            v = feval(class(v),builtin('reshape',v,varargin{:}),v.exponents);
        end
        function v = round(v)
            warning('DimVar:round',...
                'Unexpected results likely when using round.')
            v = feval(class(v),round(double(v)),v.exponents);
        end
        function v = sort(v,varargin)
            v = feval(class(v),builtin('sort',v,varargin{:}),v.exponents);
        end
        function v = std(v,varargin)
            v = feval(class(v),builtin('std',v,varargin{:}),v.exponents);
        end
        function v = sum(v,varargin)
            v = feval(class(v),builtin('sum',v,varargin{:}),v.exponents);
        end
        function v = transpose(v)
            v = feval(class(v),double(v).',v.exponents);
        end
        function v = uminus(v)
            v = feval(class(v),-double(v),v.exponents);
        end
        function v = uplus(v)
        end
        
        %% Logical
        function tf = eq(v1,v2)
            bicompatibilitycheck(v1,v2)
            tf = double(v1) == double(v2);
        end
        function tf = ge(v1,v2)
            bicompatibilitycheck(v1,v2)
            tf = double(v1) >= double(v2);
        end
        function tf = gt(v1,v2)
            bicompatibilitycheck(v1,v2)
            tf = double(v1) > double(v2);
        end
        function tf = le(v1,v2)
            bicompatibilitycheck(v1,v2)
            tf = double(v1) <= double(v2);
        end
        function tf = lt(v1,v2)
            bicompatibilitycheck(v1,v2)
            tf = double(v1) < double(v2);
        end
        function tf = ne(v1,v2)
            bicompatibilitycheck(v1,v2)
            tf = double(v1) ~= double(v2);
        end
        
        function tf = isequal(varargin)
            tf = iscompatible(varargin{:}) && builtin('isequal',varargin{:});
        end
        
        %% Validators (mustBe...)
        function mustBeGreaterThan(v1,v2)
            bicompatibilitycheck(v1,v2)
            mustBeGreaterThan(double(v1),double(v2))
        end
        function mustBeGreaterThanOrEqual(v1,v2)
            bicompatibilitycheck(v1,v2)
            mustBeGreaterThanOrEqual(double(v1),double(v2))
        end
        function mustBeLessThan(v1,v2)
            bicompatibilitycheck(v1,v2)
            mustBeLessThan(double(v1),double(v2))
        end
        function mustBeLessThanOrEqual(v1,v2)
            bicompatibilitycheck(v1,v2)
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
        % histogram; patch; line; plot, plot3, surf
    end
end