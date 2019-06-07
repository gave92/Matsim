classdef Subsystem < matsim.library.block
    properties (Access = private)
        % Handle to input ports
        simInport
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
            elseif this.getUserData('created') == 1
                % Subsystem already exists, fill input and output ports
                inports = matsim.helpers.findBlock(this.handle,'SearchDepth',1,'BlockType','Inport');
                for i = 1:length(inports)
                    this.simInport = concat(this.simInport,matsim.library.block('name',get(inports(i),'name'),'parent',this));
                    this.setInput(i,'value',{},'type','input');
                end
                enables = matsim.helpers.findBlock(this.handle,'SearchDepth',1,'BlockType','EnablePort');
                for i = 1:length(enables)
                    this.simInport = concat(this.simInport,matsim.library.block('name',get(enables(i),'name'),'parent',this));
                    this.setInput(i+length(inports),'value',{},'type','enable');
                end
                triggers = matsim.helpers.findBlock(this.handle,'SearchDepth',1,'BlockType','TriggerPort');
                for i = 1:length(triggers)
                    this.simInport = concat(this.simInport,matsim.library.block('name',get(triggers(i),'name'),'parent',this));
                    this.setInput(i+length(inports)+length(enables),'value',{},'type','trigger');
                end
                outports = matsim.helpers.findBlock(this.handle,'SearchDepth',1,'BlockType','Outport');
                for i = 1:length(outports)
                    this.simOutport = concat(this.simOutport,matsim.library.block('name',get(outports(i),'name'),'parent',this));
                end
            elseif this.getUserData('created') == 2
                inports = matsim.helpers.findBlock(this.handle,'SearchDepth',1,'BlockType','Inport');
                enables = matsim.helpers.findBlock(this.handle,'SearchDepth',1,'BlockType','EnablePort');
                triggers = matsim.helpers.findBlock(this.handle,'SearchDepth',1,'BlockType','TriggerPort');
                inport_idx = 1; enable_idx = 1; trigger_idx = 1;
                for i = 1:length(this.inputs)
                    if strcmp(this.inputs{i}.type,'input')
                        this.simInport = concat(this.simInport,matsim.library.block('name',get(inports(inport_idx),'name'),'parent',this));
                        inport_idx = inport_idx+1;
                    elseif strcmp(this.inputs{i}.type,'enable')
                        this.simInport = concat(this.simInport,matsim.library.block('name',get(enables(enable_idx),'name'),'parent',this));
                        enable_idx = enable_idx+1;
                    elseif strcmp(this.inputs{i}.type,'trigger')
                        this.simInport = concat(this.simInport,matsim.library.block('name',get(triggers(trigger_idx),'name'),'parent',this));
                        trigger_idx = trigger_idx+1;
                    end                    
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
            enable = matsim.library.block('type','Enable','parent',this,args{:});
            this.setInput(this.inlen+1,'value',input,'type','enable');
            this.simInport = concat(this.simInport,enable);
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
            trigger = matsim.library.block('type','Trigger','parent',this,args{:});
            this.setInput(this.inlen+1,'value',input,'type','trigger');
            this.simInport = concat(this.simInport,trigger);
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
            
            if index <= this.inlen
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
        function inlen = inlen(this)
            inlen = length(this.simInport);
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

            if index <= this.outlen
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
        function outlen = outlen(this)
            outlen = length(this.simOutport);
        end
        
        function [] = setHeight(this)
            pos = this.get('position');
            pos(4) = pos(2)+42*max([1,this.inlen,this.outlen]);
            this.set('position',pos);
        end
    end
end
