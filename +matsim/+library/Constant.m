classdef Constant < matsim.library.block
    properties

    end
    
    methods
        function this = Constant(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addRequired(p,'Value',@(x) ischar(x) || isnumeric(x));
            addParamValue(p,'parent','',@(x) ischar(x) || ishandle(x) || isa(x,'matsim.library.block') || isa(x,'matsim.library.simulation'));
            parse(p,varargin{:})
            
            Value = p.Results.Value;
            parent = p.Results.parent;
            args = matsim.helpers.validateArgs(p.Unmatched);
            
            this = this@matsim.library.block('type','Constant','parent',parent,args{:});
            this.set({'Value',Value,'VectorParams1D','off'})
        end
    end
end

