classdef Subsystem < matsim.library.block
    properties (Access = private)
        % Handle to input ports
        simInport
        % Handle to enable ports
        simEnable
        % Handle to trigger ports
        simTrigger
        % Handle to output ports
        simOutport
    end
    
    methods
        function this = Subsystem(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addOptional(p,'inputs',{},@(x) isnumeric(x) || iscell(x) || isa(x,'matsim.library.block'));
            addParamValue(p,'parent','',@(x) ischar(x) || ishandle(x) || isa(x,'matsim.library.block') || isa(x,'matsim.library.simulation'));
            parse(p,varargin{:})
            
            inputs = p.Results.inputs;
            if ~iscell(inputs)
                inputs = {inputs};
            end
            
            parent = matsim.helpers.getValidParent(inputs{:},p.Results.parent);
            args = matsim.helpers.unpack(p.Unmatched);
            
            % validateattributes(parent,{'char'},{'nonempty'},'','parent')
            if isempty(parent)
                parent = gcs;
            end
            
            this = this@matsim.library.block('type','SubSystem','parent',parent,args{:});
            
            if this.getUserData('created') == 0
                % Subsystem was created, delete default content
                Simulink.SubSystem.deleteContents(this.handle);

                for i = 1:length(inputs)
                    % obj.simInport = builtin('horzcat',obj.simInport,matsim.library.block('In1',obj));
                    this.simInport = concat(this.simInport,matsim.library.block('type','In1','parent',this));
                end
                
                this.setInputs(inputs);
                this.setHeight();            
            else
                % Subsystem already exists, fill input and output ports
                inports = matsim.helpers.findBlock(this.handle,'SearchDepth',1,'BlockType','Inport');
                enables = matsim.helpers.findBlock(this.handle,'SearchDepth',1,'BlockType','EnablePort');
                triggers = matsim.helpers.findBlock(this.handle,'SearchDepth',1,'BlockType','TriggerPort');
                for i = 1:length(inports)
                    this.simInport = concat(this.simInport,matsim.library.block('name',get(inports(i),'name'),'parent',this));
                end
                for i = 1:length(enables)
                    this.simEnable = concat(this.simEnable,matsim.library.block('name',get(enables(i),'name'),'parent',this));
                end
                for i = 1:length(triggers)
                    this.simTrigger = concat(this.simTrigger,matsim.library.block('name',get(triggers(i),'name'),'parent',this));
                end
                outports = matsim.helpers.findBlock(this.handle,'SearchDepth',1,'BlockType','Outport');
                for i = 1:length(outports)
                    this.simOutport = concat(this.simOutport,matsim.library.block('name',get(outports(i),'name'),'parent',this));
                end                
            end
        end
        
        function enable = enable(this,varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addOptional(p,'input',{},@(x) isnumeric(x) || isempty(x) || isa(x,'matsim.library.block'));
            parse(p,varargin{:})
            
            input = p.Results.input;
            args = matsim.helpers.unpack(p.Unmatched);
            
            if isempty(this.simEnable)
                enable = matsim.library.block('type','Enable','parent',this,args{:});
                this.setInput(length(this.simEnable)+1,'value',input,'type','enable');
                this.simEnable = concat(this.simEnable,enable);
            else
                this.setInput(length(this.simEnable),'value',input,'type','enable');
            end
        end
        
        function trigger = trigger(this,varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addOptional(p,'input',{},@(x) isnumeric(x) || isempty(x) || isa(x,'matsim.library.block'));
            parse(p,varargin{:})
            
            input = p.Results.input;
            args = matsim.helpers.unpack(p.Unmatched);
            
            if isempty(this.simTrigger)
                trigger = matsim.library.block('type','Trigger','parent',this,args{:});
                this.setInput(length(this.simTrigger)+1,'value',input,'type','trigger');
                this.simTrigger = concat(this.simTrigger,trigger);
            else
                this.setInput(length(this.simTrigger),'value',input,'type','trigger');
            end
        end
        
        function in = in(this,index,varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addRequired(p,'index',@isnumeric)
            addOptional(p,'input',{},@(x) isnumeric(x) || isempty(x) || isa(x,'matsim.library.block'));
            parse(p,index,varargin{:})
            
            index = p.Results.index;
            input = p.Results.input;
            args = matsim.helpers.unpack(p.Unmatched);
            
            if index <= length(this.simInport)
                % Return inport block
                in = this.simInport(index);
                set(in.handle,args{:});
                if ~any(strcmp(p.UsingDefaults,'input'))
                    this.setInput(index,'value',input);
                end
            else
                % Create new inport
                in = matsim.library.block('type','In1','parent',this,args{:});
                this.simInport = concat(this.simInport,in);
                this.setInput(index,'value',input);
                this.setHeight();
            end
        end
        
        function out = out(this,index,varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addRequired(p,'index',@isnumeric)
            addOptional(p,'input',{},@(x) isnumeric(x) || isempty(x) || isa(x,'matsim.library.block'));
            parse(p,index,varargin{:})
            
            index = p.Results.index;
            input = p.Results.input;
            args = matsim.helpers.unpack(p.Unmatched);

            if index <= length(this.simOutport)
                % Return outport block
                out = this.simOutport(index);
                set(out.handle,args{:});
                if ~any(strcmp(p.UsingDefaults,'input'))
                    out.setInputs({input});
                end
            else
                % Create new outport
                out = matsim.library.block('type','Out1','parent',this,args{:});
                out.setInputs({input});
                this.simOutport = concat(this.simOutport,out);
                this.setHeight();
            end
        end
        
        function [] = setHeight(this)
            pos = this.get('position');
            pos(4) = pos(2)+42*max([1,length(this.simInport),length(this.simOutport)]);
            this.set('position',pos);
        end
    end
end
