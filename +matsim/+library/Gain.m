function blk = Gain(varargin)
%GAIN Creates a simulink Gain block.
% Syntax:
%   blk = Gain(INPUT,'Gain',GAIN);
%     The block specified as INPUT will be connected to the input port of this block.
%     GAIN can be number or string (variable name)
%
% Example:
%   in1 = Constant('var1');
%   blk = Gain(in1,'Gain','Mass');
%   blk = Gain(in1,'Gain',0.5);
% 
%   See also UNARY_OPERATOR.

    blk = matsim.library.unary_operator(varargin{:},'BlockName','Gain');
    
end
