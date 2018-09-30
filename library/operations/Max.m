classdef Max < binary_operator
    properties
        
    end
    
    methods
        function this = Max(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;            
            addOptional(p,'b1',{},@(x) isnumeric(x) || isempty(x) || isa(x,'block'));
            addOptional(p,'b2',{},@(x) isnumeric(x) || isempty(x) || isa(x,'block'));
            parse(p,varargin{:})
            
            b1 = p.Results.b1;
            b2 = p.Results.b2;
            args = helpers.validateArgs(p.Unmatched);
            
            this = this@binary_operator(b1,b2,'ops','MinMax','Function','Max','Inputs',mat2str(2),args{:});
        end
    end
    
end

