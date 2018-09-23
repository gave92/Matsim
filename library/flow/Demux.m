classdef Demux < unary_operator
    properties
        
    end
    
    methods
        function this = Demux(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;            
            addOptional(p,'b1',{},@(x) isnumeric(x) || isempty(x) || isa(x,'block') || isa(x,'block_input'));
            addParamValue(p,'outputs',{},@(x) ischar(x) || isnumeric(x));
            parse(p,varargin{:})
            
            b1 = p.Results.b1;
            outputs = p.Results.outputs;
            args = helpers.validateArgs(p.Unmatched);
            
            this = this@unary_operator(b1,'ops','Demux',args{:});
            if ischar(outputs)
                this.set('Outputs',outputs)
            elseif isnumeric(outputs)
                this.set('Outputs',mat2str(outputs))
            end
        end
    end
    
end

