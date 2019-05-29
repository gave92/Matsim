classdef Tan < matsim.library.unary_operator
    properties
        
    end
    
    methods
        function this = Tan(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addOptional(p,'b1',{},@(x) isnumeric(x) || isempty(x) || isa(x,'matsim.library.block'));
            parse(p,varargin{:})
          
            b1 = p.Results.b1;
            args = matsim.helpers.validateArgs(p.Unmatched);
            
            this = this@matsim.library.unary_operator(b1,'ops','Trigonometric Function','Operator','Tan',args{:});
        end
    end
    
end

