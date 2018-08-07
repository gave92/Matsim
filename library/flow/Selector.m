classdef Selector < unary_operator
    properties
        
    end
    
    methods
        function this = Selector(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;            
            addOptional(p,'b1',{},@(x) isnumeric(x) || isempty(x) || isa(x,'block') || isa(x,'block_input'));
            addParamValue(p,'indices',[1,3],@(x) isnumeric(x));
            addParamValue(p,'width',3,@(x) isnumeric(x));
            parse(p,varargin{:})
            
            b1 = p.Results.b1;
            indices = p.Results.indices;
            width = p.Results.width;
            args = helpers.unpack(p.Unmatched);
            
            this = this@unary_operator(b1,'ops','Selector',args{:});
            this.set({'NumberOfDimensions','1','IndexOptions','Index vector (dialog)','Indices',mat2str(indices),'InputPortWidth',mat2str(width)})
        end
    end
    
end

