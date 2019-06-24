function blk = Sin(varargin)
%SIN Creates a simulink Sin block.
% Example:
%   input = Constant('var1');
%   blk = Sin(input,'Name','mySin');
% 
%   See also UNARY_OPERATOR.

    blk = matsim.library.unary_operator(varargin{:},'BlockName','Trigonometric Function','Operator','Sin');
end
