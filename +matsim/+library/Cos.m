function blk = Cos(varargin)
%COS Creates a simulink Cos block.
% Example:
%   input = Constant('var1');
%   blk = Cos(input,'Name','myCos');
% 
%   See also UNARY_OPERATOR.

    blk = matsim.library.unary_operator(varargin{:},'BlockName','Trigonometric Function','Operator','Cos');
end
