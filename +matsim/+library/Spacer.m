function blk = Spacer(varargin)
%SPACER Creates a virtual spacing block.
% Syntax:
%   blk = Spacer(INPUT);
%     The block specified as INPUT will be connected to the input port of this block.
%
% Example:
%   in1 = Constant('var1');
%   blk = Gain(Spacer(in1),'Gain','Mass');
% 
%   See also UNARY_OPERATOR.

    blk = matsim.library.unary_operator(varargin{:},'BlockName','Gain');
    blk.set('isvirtual',true);
    
end
