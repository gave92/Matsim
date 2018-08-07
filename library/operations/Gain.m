classdef Gain < unary_operator
    properties
        
    end
    
    methods
        function this = Gain(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;            
            addOptional(p,'b1',{},@(x) isnumeric(x) || isempty(x) || isa(x,'block') || isa(x,'block_input'));
            addParamValue(p,'value',{},@(x) ischar(x) || isnumeric(x));
            parse(p,varargin{:})
            
            b1 = p.Results.b1;
            value = p.Results.value;
            args = helpers.unpack(p.Unmatched);
            
            this = this@unary_operator(b1,'ops','Gain',args{:});
            if ischar(value)
                this.set('Gain',value)
            elseif isnumeric(value)
                this.set('Gain',mat2str(value))
            end
        end
    end
    
end

