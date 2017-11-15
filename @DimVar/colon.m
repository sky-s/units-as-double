function v = colon(varargin)

compatibilitycheck(varargin{:});

v = varargin{1};
v = feval(class(v),builtin('colon',varargin{:}),v.exponents);