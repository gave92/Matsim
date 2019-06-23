function blk = Abs(varargin)
%ABS Creates a simulink Abs block.
% Example:
%   input = Constant('var1');
%   blk = Abs(input,'Name','myAbs');
% 
%   See also UNARY_OPERATOR.

    blk = matsim.library.unary_operator(varargin{:},'ops','Abs');
end
