classdef FromWorkspace < matsim.library.block        
    properties

    end
    
    methods
        function this = FromWorkspace(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addRequired(p,'varname',@(x) ischar(x) || isnumeric(x));
            addParamValue(p,'parent','',@(x) ischar(x) || ishandle(x) || isa(x,'matsim.library.block') || isa(x,'matsim.library.simulation'));
            parse(p,varargin{:})
            
            varname = p.Results.varname;
            parent = p.Results.parent;
            args = matsim.helpers.validateArgs(p.Unmatched);
            
            this = this@matsim.library.block('type','From Workspace','parent',parent,args{:});
            
            if ~isempty(varname)
                this.set('VariableName',varname)
            end
        end               
    end
end

