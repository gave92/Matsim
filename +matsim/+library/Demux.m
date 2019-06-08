classdef Demux < matsim.library.unary_operator
    properties
        
    end
    
    methods
        function this = Demux(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;            
            addOptional(p,'b1',{},@(x) isnumeric(x) || isempty(x) || isa(x,'matsim.library.block'));
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

