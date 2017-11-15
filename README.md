# units-as-double
An exercise that explored a different take on the Matlab Physical Units Toolbox (https://github.com/sky-s/physical-units-for-matlab) by subclassing the built-in double.

There is some elegance to the approach. However, because the only way for a method to return a DimVar is to call the constructor, it will always be slower than the original Physical Units Toolbox.
