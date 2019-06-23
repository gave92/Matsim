function blk = Tan(varargin)
%TAN Creates a simulink Tan block.
% Example:
%   input = Constant('var1');
%   blk = Tan(input,'Name','myTan');
% 
%   See also UNARY_OPERATOR.

    blk = matsim.library.unary_operator(varargin{:},'ops','Trigonometric Function','Operator','Tan');
end

