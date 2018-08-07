classdef Merge < block
    properties

    end
    
    methods
        function this = Merge(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addOptional(p,'inputs',{},@(x) isnumeric(x) || iscell(x) || isa(x,'block') || isa(x,'block_input'));
            addParamValue(p,'parent','',@(x) ischar(x) || ishandle(x) || isa(x,'block') || isa(x,'simulation'));
            parse(p,varargin{:})
            
            inputs = p.Results.inputs;
            if ~iscell(inputs)
                inputs = {inputs};
            end
            
            parent = helpers.getValidParent(inputs{:},p.Results.parent);
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
                    inputs{i} = Constant(inputs{i},'parent',parent);
                end
                if strcmp(inputs{i}.get('BlockType'),'Goto')
                    inputs{i} = REF(inputs{i}.get('GotoTag'));
                end
            end
            
            this = this@block('type','Merge','parent',parent,args{:});
            this.set('Inputs',mat2str(length(inputs)));
            this.setInputs(inputs);                       
        end
    end
end

