classdef REF < matsim.library.block
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
            addOptional(p,'b1',{},@(x) isnumeric(x) || isempty(x) || isa(x,'matsim.library.block'));
            addParamValue(p,'parent','',@(x) ischar(x) || ishandle(x) || isa(x,'matsim.library.block') || isa(x,'matsim.library.simulation'));
            parse(p,varargin{:})

            inputs = {p.Results.b1};
            tag = p.Results.tag;
            parent = matsim.helpers.getValidParent(inputs{:},p.Results.parent);
            args = matsim.helpers.validateArgs(p.Unmatched);
            
            if isempty(parent)
                parent = gcs;
            end            
            
            if isempty(p.Results.b1)
                type = 'From';
            else
                type = 'Goto';
            end
            
            this = this@matsim.library.block('type',type,'parent',parent,args{:});
            this.set('ShowName','off');
            if this.getUserData('created') == 0
                this.setInputs(inputs);
            end
            
            if isnumeric(tag)
                tag = ['ref', mat2str(tag)];
            end
            this.set('GotoTag',tag);
            
            location = this.get('Position');
            location(3) = location(1)+max(40,10*length(tag));
            this.set('Position',location);           
        end       
    end   
end

