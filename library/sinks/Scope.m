classdef Scope < block
    properties

    end
    
    methods
        function this = Scope(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addOptional(p,'inputs',{},@(x) isnumeric(x) || iscell(x) || isa(x,'block') || isa(x,'block_input'));
            addParamValue(p,'numPorts',1,@isnumeric);
            addParamValue(p,'parent','',@(x) ischar(x) || ishandle(x) || isa(x,'block') || isa(x,'simulation'));
            parse(p,varargin{:})
            
            inputs = p.Results.inputs;
            if ~iscell(inputs)
                inputs = {inputs};
            end
            
            parent = helpers.getValidParent(inputs{:},p.Results.parent);
            numPorts = p.Results.numPorts;
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
            
            this = this@block('type','Scope','parent',parent,args{:});
            
            if getversion() >= 2015
                scope_configuration = this.get('ScopeConfiguration');
                scope_configuration.NumInputPorts = mat2str(max(numPorts,length(inputs)));
                scope_configuration.LayoutDimensions = [max(numPorts,length(inputs)), 1]; % Rows, columns
            else
                this.set('NumInputPorts',mat2str(max(numPorts,length(inputs))));
            end

            this.setInputs(inputs);
        end
        
        function [] = open(this)
            set_param(this.handle,'open','on');
        end
    end
end

