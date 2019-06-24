classdef Subsystem < matsim.library.block
%SUBSYSTEM Creates a simulink Subsystem block.
% Syntax:
%   blk = Subsystem();
%     Creates an empty Subsystem block with no inports or outports
%   blk = Subsystem(INPUTS);
%     INPUTS blocks will be connected to the block input ports.
%     INPUTS can be:
%       - an empty cell {}
%       - a matsim block
%       - a number
%       - a cell array of the above
%     If INPUTS is a number a Constant block with that value will
%     be created.
%   blk = Subsystem(INPUTS,ARGS);
%     ARGS is an optional list of parameter/value pairs specifying simulink
%     block properties.
%
% Subsystem Methods:
%    enable - adds an enable port
%    trigger - adds a trigger port
%    reset - adds a reset port
%    action - adds an action port
%    in - adds an input port
%    out - adds an output port
% 
% Example:
%   in1 = Constant('var1');
%   in2 = FromWorkspace('var2');
%   s = Subsystem({},'name','TEST'); % Subsystem with no inports
%   s.in(1,in1,'name','VAR1');       % Add inport connected to in1
%   s.in(2,in2,'name','VAR2');       % Add inport connected to in2
%   res = s.in(1)+s.in(2)./0.5;      % This operation happens inside the Subsystem
%   s.out(1,res,'name','RES')        % Add outport connected to res
%   s.enable(1)                      % Add enable port connected to a Constant
% 
%   See also BLOCK.

    properties (Access = protected)
        % Handle to input ports
        simInport
        % Handle to enable ports
        simEnable
        % Handle to trigger ports
        simTrigger
        % Handle to reset ports
        simReset
        % Handle to action ports
        simAction
        % Handle to output ports
        simOutport
    end
    
    methods
        function this = Subsystem(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            p.KeepUnmatched = true;
            addOptional(p,'inputs',[],@(x) isnumeric(x) || iscell(x) || isa(x,'matsim.library.block'));
            addParamValue(p,'parent','',@(x) ischar(x) || ishandle(x) || isa(x,'matsim.library.block') || isa(x,'matsim.library.simulation'));
            parse(p,varargin{:})
            
            inputs = p.Results.inputs;
            if ~iscell(inputs)
                inputs = {inputs};
            end
            
            parent = matsim.helpers.getValidParent(inputs{:},p.Results.parent);
            args = matsim.helpers.unpack(p.Unmatched);
            
            if isempty(parent)
                parent = gcs;
            end
            
            this = this@matsim.library.block('BlockName','SubSystem','parent',parent,args{:});
            
            if this.getUserData('created') == 0
                % Subsystem was created, delete default content
                Simulink.SubSystem.deleteContents(this.handle);

                if matsim.helpers.isArgSpecified(p,'inputs')
                    for i = 1:length(inputs)
                        this.simInport = concat(this.simInport,matsim.library.block('BlockType','Inport','parent',this));
                    end
                end
            else
                % Subsystem already exists, fill input and output ports
                inports = matsim.helpers.findBlock(this.handle,'SearchDepth',1,'BlockType','Inport');
                enables = matsim.helpers.findBlock(this.handle,'SearchDepth',1,'BlockType','EnablePort');
                triggers = matsim.helpers.findBlock(this.handle,'SearchDepth',1,'BlockType','TriggerPort');
                resets = matsim.helpers.findBlock(this.handle,'SearchDepth',1,'BlockType','ResetPort');
                actions = matsim.helpers.findBlock(this.handle,'SearchDepth',1,'BlockType','ActionPort');
                for i = 1:length(inports)
                    this.simInport = concat(this.simInport,matsim.library.block('name',get(inports(i),'name'),'parent',this));
                end
                for i = 1:length(enables)
                    this.simEnable = concat(this.simEnable,matsim.library.block('name',get(enables(i),'name'),'parent',this));
                end
                for i = 1:length(triggers)
                    this.simTrigger = concat(this.simTrigger,matsim.library.block('name',get(triggers(i),'name'),'parent',this));
                end
                for i = 1:length(resets)
                    this.simReset = concat(this.simReset,matsim.library.block('name',get(resets(i),'name'),'parent',this));
                end
                for i = 1:length(actions)
                    this.simAction = concat(this.simAction,matsim.library.block('name',get(actions(i),'name'),'parent',this));
                end
                outports = matsim.helpers.findBlock(this.handle,'SearchDepth',1,'BlockType','Outport');
                for i = 1:length(outports)
                    this.simOutport = concat(this.simOutport,matsim.library.block('name',get(outports(i),'name'),'parent',this));
                end                
            end
            
            if matsim.helpers.isArgSpecified(p,'inputs')
                this.setInputs(inputs);
            end
        end
        
        function enable = enable(this,varargin)
            %ENABLE Adds an enable port
            % Syntax:
            %   s.enable(INPUT)
            %     INPUT block will be connected to the block enable port.
            %     INPUT can be:
            %       - an empty cell {}
            %       - a matsim block
            %       - a number
            %     If INPUT is a number a Constant block with that value will
            %     be created.
            % 
            % Example:
            %   s = Subsystem({{}});
            %   s.enable(Delay(1))
            
            p = inputParser;
            p.CaseSensitive = false;
            p.KeepUnmatched = true;
            addOptional(p,'input',{},@(x) isnumeric(x) || isempty(x) || isa(x,'matsim.library.block'));
            parse(p,varargin{:})
            
            input = p.Results.input;
            args = matsim.helpers.unpack(p.Unmatched);
            
            if isempty(this.simEnable)
                enable = matsim.library.block('BlockType','EnablePort','parent',this,args{:});
                this.setInput(length(this.simEnable)+1,'value',input,'type','enable');
                this.simEnable = concat(this.simEnable,enable);
            else
                this.setInput(length(this.simEnable),'value',input,'type','enable');
            end
        end
        
        function trigger = trigger(this,varargin)
            %TRIGGER Adds a trigger port
            % Syntax:
            %   s.trigger(INPUT)
            %     INPUT block will be connected to the block trigger port.
            %     INPUT can be:
            %       - an empty cell {}
            %       - a matsim block
            %       - a number
            %     If INPUT is a number a Constant block with that value will
            %     be created.
            % 
            % Example:
            %   s = Subsystem({{}});
            %   s.trigger(Delay(1))
            
            p = inputParser;
            p.CaseSensitive = false;
            p.KeepUnmatched = true;
            addOptional(p,'input',{},@(x) isnumeric(x) || isempty(x) || isa(x,'matsim.library.block'));
            parse(p,varargin{:})
            
            input = p.Results.input;
            args = matsim.helpers.unpack(p.Unmatched);
            
            if isempty(this.simTrigger)
                trigger = matsim.library.block('BlockType','TriggerPort','parent',this,args{:});
                this.setInput(length(this.simTrigger)+1,'value',input,'type','trigger');
                this.simTrigger = concat(this.simTrigger,trigger);
            else
                this.setInput(length(this.simTrigger),'value',input,'type','trigger');
            end
        end

        function reset = reset(this,varargin)
            %RESET Adds a reset port
            % Syntax:
            %   s.reset(INPUT)
            %     INPUT block will be connected to the block reset port.
            %     INPUT can be:
            %       - an empty cell {}
            %       - a matsim block
            %       - a number
            %     If INPUT is a number a Constant block with that value will
            %     be created.
            % 
            % Example:
            %   s = Subsystem({{}});
            %   s.reset(Delay(1))
            
            p = inputParser;
            p.CaseSensitive = false;
            p.KeepUnmatched = true;
            addOptional(p,'input',{},@(x) isnumeric(x) || isempty(x) || isa(x,'matsim.library.block'));
            parse(p,varargin{:})
            
            input = p.Results.input;
            args = matsim.helpers.unpack(p.Unmatched);
            
            if isempty(this.simReset)
                reset = matsim.library.block('BlockType','ResetPort','parent',this,args{:});
                this.setInput(length(this.simReset)+1,'value',input,'type','reset');
                this.simReset = concat(this.simReset,reset);
            else
                this.setInput(length(this.simReset),'value',input,'type','reset');
            end
        end
        
        function action = action(this,varargin)
            %ACTION Adds an action port
            % Syntax:
            %   s.action(INPUT)
            %     INPUT block will be connected to the block action port.
            %     INPUT can be:
            %       - an empty cell {}
            %       - a matsim block
            %       - a number
            %     If INPUT is a number a Constant block with that value will
            %     be created.
            % 
            % Example:
            %   s = Subsystem({{}});
            %   s.action(...)
            
            p = inputParser;
            p.CaseSensitive = false;
            p.KeepUnmatched = true;
            addOptional(p,'input',{},@(x) isnumeric(x) || isempty(x) || isa(x,'matsim.library.block'));
            parse(p,varargin{:})
            
            input = p.Results.input;
            args = matsim.helpers.unpack(p.Unmatched);
            
            if isempty(this.simAction)
                action = matsim.library.block('BlockType','ActionPort','parent',this,args{:});
                this.setInput(length(this.simAction)+1,'value',input,'type','ifaction');
                this.simAction = concat(this.simAction,action);
            else
                this.setInput(length(this.simAction),'value',input,'type','ifaction');
            end
        end
        
        function in = in(this,index,varargin)
            %IN Adds an input port
            % Syntax:
            %   s.in(INDEX,INPUT)
            %     INPUT block will be connected to the INDEX block input port.
            %     INPUT can be:
            %       - an empty cell {}
            %       - a matsim block
            %       - a number
            %     If INPUT is a number a Constant block with that value will
            %     be created.
            %   s.in(INDEX,ARGS)
            %     ARGS is an optional list of parameter/value pairs specifying simulink
            %     block properties.
            % 
            % Example:
            %   s = Subsystem({{}});       % Subsystem with one (unconnected) inport
            %   s.in(2,Gain(Constant(-1))) % Connect a Gain to the second inport
            
            p = inputParser;
            p.CaseSensitive = false;
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
                in = matsim.library.block('BlockType','Inport','parent',this,args{:});
                this.simInport = concat(this.simInport,in);
                this.setInput(index,'value',input);
            end
        end
        
        function out = out(this,index,varargin)
            %OUT Adds an output port
            % Syntax:
            %   s.out(INDEX,INPUT)
            %     INPUT block will be connected to the INDEX block output port.
            %     INPUT can be:
            %       - an empty cell {}
            %       - a matsim block
            %       - a number
            %     If INPUT is a number a Constant block with that value will
            %     be created.
            %   s.out(INDEX,ARGS)
            %     ARGS is an optional list of parameter/value pairs specifying simulink
            %     block properties.
            % 
            % Example:
            %   s = Subsystem({});                      % Subsystem with no inport
            %   s.in(1,'name','in1')                    % Creates an inport
            %   s.in(2,'name','in2')                    % Creates an inport
            %   s.out(1,'name','res');                  % Creates an outport
            %   s.out(1,s.in(1)+Constant(1,'parent',s)) % Connects outport inside subsystem
            
            p = inputParser;
            p.CaseSensitive = false;
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
                out = matsim.library.block('BlockType','Outport','parent',this,args{:});
                out.setInputs({input});
                this.simOutport = concat(this.simOutport,out);
            end
        end
        
        function ports = getPorts(this)
            ports = struct;
            ports.enable = this.simEnable;
            ports.trigger = this.simTrigger;
            ports.reset = this.simReset;
            ports.action = this.simAction;
            ports.inport = this.simInport;
            ports.outport = this.simOutport;
        end
    end
end
