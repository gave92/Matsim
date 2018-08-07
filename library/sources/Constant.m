classdef Constant < block
    properties

    end
    
    methods
        function this = Constant(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addRequired(p,'value',@(x) ischar(x) || isnumeric(x));
            addParamValue(p,'parent','',@(x) ischar(x) || ishandle(x) || isa(x,'block') || isa(x,'simulation'));
            parse(p,varargin{:})
            
            value = p.Results.value;
            parent = p.Results.parent;
            args = helpers.unpack(p.Unmatched);
            
            this = this@block('type','Constant','parent',parent,args{:});
            if ischar(value)
                this.set('Value',value).set('VectorParams1D','off')
            elseif isnumeric(value)
                this.set('Value',mat2str(value)).set('VectorParams1D','off')
            end
        end
    end
end

