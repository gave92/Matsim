classdef FromWorkspace < block        
    properties

    end
    
    methods
        function this = FromWorkspace(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addRequired(p,'varname',@(x) ischar(x) || isnumeric(x));
            addParamValue(p,'parent','',@(x) ischar(x) || ishandle(x) || isa(x,'block') || isa(x,'simulation'));
            parse(p,varargin{:})
            
            varname = p.Results.varname;
            parent = p.Results.parent;
            args = helpers.unpack(p.Unmatched);
            
            this = this@block('type','From Workspace','parent',parent,args{:});
            
            if ~isempty(varname)
                this.set('VariableName',varname)
            end
        end               
    end
end

