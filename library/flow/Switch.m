classdef Switch < block
    properties

    end
    
    methods
        function this = Switch(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addOptional(p,'b1',{},@(x) isnumeric(x) || isempty(x) || isa(x,'block') || isa(x,'block_input'));
            addOptional(p,'b2',{},@(x) isnumeric(x) || isempty(x) || isa(x,'block') || isa(x,'block_input'));
            addOptional(p,'cond',{},@(x) isnumeric(x) || isempty(x) || isa(x,'block') || isa(x,'block_input'));
            addParamValue(p,'parent','',@(x) ischar(x) || ishandle(x) || isa(x,'block') || isa(x,'simulation'));
            parse(p,varargin{:})
            
            inputs = {p.Results.b1,p.Results.b2};
            cond = p.Results.cond;
            parent = helpers.getValidParent(inputs{:},cond,p.Results.parent);
            args = helpers.unpack(p.Unmatched);
            
            % validateattributes(parent,{'char'},{'nonempty'},'','parent')
            if isempty(parent)
                parent = gcs;
            end
            for i=1:length(inputs)
                if isempty(inputs{i})
                    continue
                end
                if isnumeric(inputs{i})
                    inputs{i} = block_input(Constant(inputs{i},'parent',parent));
                end
                if strcmp(inputs{i}.get('BlockType'),'Goto')
                    inputs{i} = block_input(REF(inputs{i}.get('GotoTag')));
                end
            end
            
            if isnumeric(cond)
                cond = Constant(cond,'parent',parent);
            end
            
            this = this@block('type','Switch','parent',parent,args{:});
            this.set('Criteria','u2 ~= 0')            
            this.setInputs({inputs{1},cond(:),inputs{2}});
        end
    end
end

