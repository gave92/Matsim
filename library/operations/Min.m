classdef Min < binary_operator
    properties
        
    end
    
    methods
        function this = Min(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addOptional(p,'b1',{},@(x) isnumeric(x) || isempty(x) || isa(x,'block') || isa(x,'block_input'));
            addOptional(p,'b2',{},@(x) isnumeric(x) || isempty(x) || isa(x,'block') || isa(x,'block_input'));
            parse(p,varargin{:})
            
            b1 = p.Results.b1;
            b2 = p.Results.b2;
            args = helpers.unpack(p.Unmatched);
            
            this = this@binary_operator(b1,b2,'ops','MinMax','Function','Min','Inputs',mat2str(2),args{:});
        end
    end
    
end

