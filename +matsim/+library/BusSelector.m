classdef BusSelector < matsim.library.unary_operator
    properties
        
    end
    
    methods
        function this = BusSelector(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addOptional(p,'b1',{},@(x) isnumeric(x) || isempty(x) || isa(x,'matsim.library.block'));
            addParamValue(p,'OutputSignals',{},@(x) ischar(x) || iscellstr(x));
            parse(p,varargin{:})
            
            b1 = p.Results.b1;
            outputsignals = p.Results.OutputSignals;
            args = matsim.helpers.validateArgs(p.Unmatched);
            
            this = this@matsim.library.unary_operator(b1,'ops','Bus Selector',args{:});
            if ~iscell(outputsignals), outputsignals = {outputsignals}; end
            if ~isempty(outputsignals), this.set('OutputSignals',strjoin(outputsignals,',')); end
        end
    end
    
end

