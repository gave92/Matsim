classdef BusSelector < unary_operator
    properties
        
    end
    
    methods
        function this = BusSelector(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addOptional(p,'b1',{},@(x) isnumeric(x) || isempty(x) || isa(x,'block'));
            addParamValue(p,'signals',{},@(x) ischar(x) || iscellstr(x));
            parse(p,varargin{:})
            
            b1 = p.Results.b1;
            signals = p.Results.signals;
            args = helpers.validateArgs(p.Unmatched);
            
            this = this@unary_operator(b1,'ops','Bus Selector',args{:});
            if ~iscell(signals), signals = {signals}; end
            if ~isempty(signals), this.set('OutputSignals',strjoin(signals,',')); end
        end
    end
    
end

