classdef Switch < block
    properties

    end
    
    methods
        function this = Switch(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addOptional(p,'b1',{},@(x) isnumeric(x) || isempty(x) || isa(x,'block'));
            addOptional(p,'b2',{},@(x) isnumeric(x) || isempty(x) || isa(x,'block'));
            addOptional(p,'cond',{},@(x) isnumeric(x) || isempty(x) || isa(x,'block'));
            addParamValue(p,'parent','',@(x) ischar(x) || ishandle(x) || isa(x,'block') || isa(x,'simulation'));
            parse(p,varargin{:})
            
            inputs = {p.Results.b1,p.Results.cond,p.Results.b2};
            parent = helpers.getValidParent(inputs{:},p.Results.parent);
            args = helpers.validateArgs(p.Unmatched);
            
            if isempty(parent)
                parent = gcs;
            end
            
            this = this@block('type','Switch','parent',parent,args{:});
            this.set('Criteria','u2 ~= 0')            
            this.setInputs(inputs);
        end
    end
end

