function blk = Sign(varargin)
%SIGN Creates a simulink Sign block.
% Example:
%   input = Constant('var1');
%   blk = Sign(input,'Name','mySign');
% 
%   See also UNARY_OPERATOR.

    blk = matsim.library.unary_operator(varargin{:},'BlockName','Sign');
end
