function blk = Terminator(varargin)
%TERMINATOR Creates a simulink Terminator block.
% Example:
%   input = Demux();
%   blk = Terminator(input.outport(2),'Name','myTerminator');
% 
%   See also UNARY_OPERATOR.

    blk = matsim.library.unary_operator(varargin{:},'BlockName','Terminator');
end
