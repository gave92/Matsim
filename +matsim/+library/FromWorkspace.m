classdef FromWorkspace < matsim.library.block        
    properties

    end
    
    methods
        function this = FromWorkspace(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addRequired(p,'VariableName',@(x) ischar(x) || isnumeric(x));
            addParamValue(p,'parent','',@(x) ischar(x) || ishandle(x) || isa(x,'matsim.library.block') || isa(x,'matsim.library.simulation'));
            parse(p,varargin{:})
            
            VariableName = p.Results.VariableName;
            parent = p.Results.parent;
            args = matsim.helpers.validateArgs(p.Unmatched);
            
            this = this@matsim.library.block('type','From Workspace','parent',parent,args{:});
            
            if ~isempty(VariableName)
                this.set('VariableName',VariableName)
            end
        end               
    end
end

