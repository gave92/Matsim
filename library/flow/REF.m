classdef REF < block
    %REF From or Goto block
    properties
        
    end
    
    methods
        function this = REF(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addRequired(p,'tag',@(x) isnumeric(x) || ischar(x));
            addOptional(p,'b1',{},@(x) isnumeric(x) || isempty(x) || isa(x,'block') || isa(x,'block_input'));
            addParamValue(p,'parent','',@(x) ischar(x) || ishandle(x) || isa(x,'block') || isa(x,'simulation'));
            parse(p,varargin{:})

            inputs = {p.Results.b1};
            tag = p.Results.tag;
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
                    inputs{i} = block_input(Constant(inputs{i},'parent',parent));
                end
                if strcmp(inputs{i}.get('BlockType'),'Goto')
                    inputs{i} = block_input(REF(inputs{i}.get('GotoTag')));
                end
            end
            
            if isempty(p.Results.b1)
                type = 'From';
            else
                type = 'Goto';
            end
            
            this = this@block('type',type,'parent',parent,args{:});
            this.set('ShowName','off');            
            this.setInputs(inputs);
            
            if isnumeric(tag)
                tag = ['ref', mat2str(tag)];
            end
            this.set('GotoTag',tag);
            
            location = this.get('Position');
            location(3) = location(1)+max(40,10*length(tag));
            this.set('Position',location);
            
            this.set('backgroundcolor','yellow');
        end       
    end   
end

