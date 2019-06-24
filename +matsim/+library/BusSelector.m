classdef BusSelector < matsim.library.unary_operator
%BUSSELECTOR Creates a simulink Bus Selector block.
% Syntax:
%   blk = BusSelector(INPUT,'OutputSignals',SIGNALS);
%     The block specified as INPUT will be connected to the input port of this block.
%     INPUT can be:
%       - an empty cell {}
%       - a Matsim block
%     SIGNALS is a cell array of strings specifying which signals to
%     extract from the inputs bus.
%   blk = BusSelector(INPUT,'OutputSignals',SIGNALS,ARGS);
%     ARGS is an optional list of parameter/value pairs specifying simulink
%     block properties.
%
% Example:
%   in1 = Constant('var1');
%   in2 = FromWorkspace('var2');
%   in1.outport(1,'name','sig1');
%   in2.outport(1,'name','sig2');
%   buscr = BusCreator({in1,in2},'parent',gcs);
% 
%   blk = BusSelector(buscr,'OutputSignals',{'sig1'});
% 
%   See also UNARY_OPERATOR.

    properties
        
    end
    
    methods
        function this = BusSelector(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            p.KeepUnmatched = true;
            addOptional(p,'b1',[],@(x) isnumeric(x) || isempty(x) || isa(x,'matsim.library.block'));
            addParamValue(p,'OutputSignals',{},@(x) ischar(x) || iscellstr(x));
            parse(p,varargin{:})

            b1 = p.Results.b1;
            outputsignals = p.Results.OutputSignals;
            args = matsim.helpers.validateArgs(p.Unmatched);
            
            this = this@matsim.library.unary_operator(b1,'BlockName','Bus Selector',args{:});
            if ~iscell(outputsignals), outputsignals = {outputsignals}; end
            if ~isempty(outputsignals), this.set('OutputSignals',strjoin(outputsignals,',')); end
        end
    end
    
end

