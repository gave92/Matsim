function blk = Atan(varargin)
%ATAN Creates a simulink Atan block.
% Example:
%   input = Constant('var1');
%   blk = Atan(input,'Name','myAtan');
% 
%   See also UNARY_OPERATOR.

    blk = matsim.library.unary_operator(varargin{:},'BlockName','Trigonometric Function','Operator','Atan');
end

