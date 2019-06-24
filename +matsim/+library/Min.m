function blk = Min(varargin)
%MIN Creates a simulink Min block.
% Example:
%   in1 = Constant('var1');
%   in2 = Constant('var2');
%   blk = Min(in1,in2,'name','myMin');
% 
%   See also BINARY_OPERATOR.

    blk = matsim.library.binary_operator(varargin{:},'BlockName','MinMax','Function','Min','Inputs',mat2str(2));
end

