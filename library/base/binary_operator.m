classdef binary_operator < block
    properties

    end
    
    methods
        function this = binary_operator(varargin)
            p = inputParser;
            p.CaseSensitive = true;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addOptional(p,'b1',{},@(x) isnumeric(x) || isempty(x) || isa(x,'block') || isa(x,'block_input'));
            addOptional(p,'b2',{},@(x) isnumeric(x) || isempty(x) || isa(x,'block') || isa(x,'block_input'));
            addParamValue(p,'ops','',@ischar);
            addParamValue(p,'parent','',@(x) ischar(x) || ishandle(x) || isa(x,'block') || isa(x,'simulation'));
            parse(p,varargin{:})
            
            inputs = {p.Results.b1,p.Results.b2};
            ops = p.Results.ops;
            parent = helpers.getValidParent(inputs{:},p.Results.parent);
            args = helpers.unpack(p.Unmatched);
            
            % validateattributes(parent,{'char'},{'nonempty'},'','parent')
            if isempty(parent)
                parent = gcs;
            end
            if isempty(ops)
                error('Invalid operator.')
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
            
            this = this@block('type',ops,'parent',parent,args{:});

            this.setInputs(inputs);
        end
    end
end

