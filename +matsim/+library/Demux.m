classdef Demux < matsim.library.unary_operator
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
            p.KeepUnmatched = true;   
            addOptional(p,'b1',[],@(x) isnumeric(x) || isempty(x) || isa(x,'matsim.library.block'));
            addParamValue(p,'Outputs',{},@(x) ischar(x) || isnumeric(x));
            parse(p,varargin{:})
            
            b1 = p.Results.b1;
            Outputs = p.Results.Outputs;
            args = matsim.helpers.validateArgs(p.Unmatched);
            
            this = this@matsim.library.unary_operator(b1,'ops','Demux',args{:});
            this.set('Outputs',Outputs)
        end
    end
    
end

