function blk = Demux(varargin)
%DEMUX Creates a simulink Demux block.
% Syntax:
%   blk = Demux(INPUT,'Outputs',OUTPUTS);
%     The block specified as INPUT will be connected to the input port of this block.
%     OUTPUTS can be an array or an integer specifying which output
%     elements of the input vector signal to extract.
%
% Example:
%   in1 = FromWorkspace('var1');
%   in2 = Constant('var2');
%   in3 = Constant('var3');
%   mux = Mux({in1,in2,in3});
% 
%   blk = Demux(mux,'Outputs',[1 2]);
% 
%   See also UNARY_OPERATOR.

    blk = matsim.library.unary_operator(varargin{:},'BlockName','Demux');
end
