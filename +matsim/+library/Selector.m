classdef Selector < matsim.library.unary_operator
    properties
        
    end
    
    methods
        function this = Selector(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;            
            addOptional(p,'b1',{},@(x) isnumeric(x) || isempty(x) || isa(x,'matsim.library.block'));
            addParamValue(p,'Indices',[1,3],@(x) isnumeric(x));
            addParamValue(p,'InputPortWidth',3,@(x) isnumeric(x));
            parse(p,varargin{:})
            
            b1 = p.Results.b1;
            Indices = p.Results.Indices;
            InputPortWidth = p.Results.InputPortWidth;
            args = matsim.helpers.validateArgs(p.Unmatched);
            
            this = this@matsim.library.unary_operator(b1,'ops','Selector',args{:});
            this.set({'NumberOfDimensions','1','IndexOptions','Index vector (dialog)','InputPortWidth',mat2str(InputPortWidth),'Indices',mat2str(Indices)})
        end
    end
    
end

