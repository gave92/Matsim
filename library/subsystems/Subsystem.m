classdef Subsystem < block
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
            addOptional(p,'inputs',{},@(x) isnumeric(x) || iscell(x) || isa(x,'block'));
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
            
            this = this@block('type','SubSystem','parent',parent,args{:});
            
            if this.getUserData('created')
                % Subsystem was created, delete default content
                Simulink.SubSystem.deleteContents(this.handle);

                for i = 1:length(inputs)
                    % obj.simInport = builtin('horzcat',obj.simInport,block('In1',obj));
                    this.simInport = concat(this.simInport,block('type','In1','parent',this));
                    set(this.simInport(end),'backgroundcolor','lightblue');
                end
                
                this.setInputs(inputs);
                this.setHeight();
            else
                % Subsystem already exists, fill input and output ports
                % inports = helpers.findBlock(this.handle,'SearchDepth',1,'BlockType','Inport','LookUnderMasks','on','FollowLinks','on');
                inports = helpers.findBlock(this.handle,'SearchDepth',1,'BlockType','Inport');
                for i = 1:length(inports)
                    this.simInport = concat(this.simInport,block('name',get(inports(i),'name'),'parent',this));
                end 
                % outports = helpers.findBlock(this.handle,'SearchDepth',1,'BlockType','Outport','LookUnderMasks','on','FollowLinks','on');
                outports = helpers.findBlock(this.handle,'SearchDepth',1,'BlockType','Outport');
                for i = 1:length(outports)
                    this.simOutport = concat(this.simOutport,block('name',get(outports(i),'name'),'parent',this));
                end 
            end
        end
        
        function enable = enable(this,varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addOptional(p,'input',{},@(x) isnumeric(x) || isempty(x) || isa(x,'block'));
            parse(p,varargin{:})
            
            input = p.Results.input;
            args = helpers.unpack(p.Unmatched);
            enable = block('type','Enable','parent',this,args{:});
            this.setInput(this.inlen+1,'value',input,'type','enable');
            this.simInport = concat(this.simInport,enable);
        end
        
        function trigger = trigger(this,varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addOptional(p,'input',{},@(x) isnumeric(x) || isempty(x) || isa(x,'block'));
            parse(p,varargin{:})
            
            input = p.Results.input;
            args = helpers.unpack(p.Unmatched);
            trigger = block('type','Trigger','parent',this,args{:});
            this.setInput(this.inlen+1,'value',input,'type','trigger');
            this.simInport = concat(this.simInport,trigger);
        end
        
        function in = in(this,index,varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addRequired(p,'index',@isnumeric)
            addOptional(p,'input',{},@(x) isnumeric(x) || isempty(x) || isa(x,'block'));
            parse(p,index,varargin{:})
            
            index = p.Results.index;
            input = p.Results.input;
            args = helpers.unpack(p.Unmatched);
            
            if index <= this.inlen
                % Return inport block
                in = this.simInport(index);
                set(in.handle,args{:});
                if ~any(strcmp(p.UsingDefaults,'input'))
                    this.setInput(index,'value',input);
                end
            else
                % Create new inport
                in = block('type','In1','parent',this,args{:});
                set(in,'backgroundcolor','lightblue');
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
            addOptional(p,'input',{},@(x) isnumeric(x) || isempty(x) || isa(x,'block'));
            parse(p,index,varargin{:})
            
            index = p.Results.index;
            input = p.Results.input;
            args = helpers.unpack(p.Unmatched);

            if index <= this.outlen
                % Return outport block
                out = this.simOutport(index);
                set(out.handle,args{:});
                if ~any(strcmp(p.UsingDefaults,'input'))
                    out.setInputs({input});
                end
            else
                % Create new outport
                out = block('type','Out1','parent',this,args{:});
                set(out,'backgroundcolor','lightblue');
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
