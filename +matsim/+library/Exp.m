function blk = Exp(varargin)
%Exp Creates a simulink exponential block.
% Example:
%   input = Constant('var1');
%   blk = Exp(input,'Name','myExp');
% 
%   See also UNARY_OPERATOR.

    blk = matsim.library.unary_operator(varargin{:},'BlockName','Math Function','Operator','exp');
end
