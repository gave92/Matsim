function blk = Max(varargin)
%MAX Creates a simulink Max block.
% Example:
%   in1 = Constant('var1');
%   in2 = Constant('var2');
%   blk = Max(in1,in2,'name','myMax');
% 
%   See also BINARY_OPERATOR.

    blk = matsim.library.binary_operator(varargin{:},'BlockName','MinMax','Function','Max','Inputs',mat2str(2));
end
