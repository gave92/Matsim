classdef Demux < unary_operator
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

    properties
        
    end
    
    methods
        function this = Demux(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;            
            addOptional(p,'b1',{},@(x) isnumeric(x) || isempty(x) || isa(x,'block'));
            addParamValue(p,'outputs',{},@(x) ischar(x) || isnumeric(x));
            parse(p,varargin{:})
            
            b1 = p.Results.b1;
            outputs = p.Results.outputs;
            args = helpers.validateArgs(p.Unmatched);
            
            this = this@unary_operator(b1,'ops','Demux',args{:});
            this.set('Outputs',outputs)
        end
    end
    
end

