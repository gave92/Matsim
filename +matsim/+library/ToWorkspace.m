classdef ToWorkspace < matsim.library.unary_operator        
    properties

    end
    
    methods
        function this = ToWorkspace(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addOptional(p,'b1',{},@(x) isnumeric(x) || isempty(x) || isa(x,'matsim.library.block'));
            addParamValue(p,'VariableName','',@(x) ischar(x) || isnumeric(x));
            parse(p,varargin{:})
            
            b1 = p.Results.b1;
            VariableName = p.Results.VariableName;            
            args = matsim.helpers.validateArgs(p.Unmatched);
            
            this = this@matsim.library.unary_operator(b1,'ops','To Workspace',args{:});
            
            if ~isempty(VariableName)
                this.set('VariableName',VariableName)
            end            
        end               
    end
end

