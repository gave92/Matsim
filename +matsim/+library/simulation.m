classdef simulation < handle
%SIMULATION Creates or loads a simulink block diagram.
% Syntax:
%   sys = simulation.load(MODEL);
%     MODEL is the name of the simulink model to be loaded. If MODEL does
%     not exist, a new simulink model will be created.
%
% Simulation Methods:
%    setSolver - set solver for this model
%    show - show the model window
%    save - save the model
%    close - close the model (without saving)
%    clear - deletes all model content
%    layout - layout and connect blocks in the model
%    open - navigate to subsystem
%    run - run simulation
%    log - log a signal
% 
% Example:
%   sys = simulation.load('my_model');            % Create or load a model named 'my_model'
%   sys.setSolver('Ts',0.01,'DiscreteOnly',true)  % Set solver for the model
%   sys.clear()                                   % Delete all blocks
%   sys.show()                                    % Show the model
%   Scope(Gain(FromWorkspace('var1'),'Gain',0.5)) % Add blocks to the model
%   sys.layout()                                  % Connect and layout the model
%   sys.save()
%   sys.close()

    properties (Access = private)
        % Handle to simulink system
        simDiagram
    end
    
    methods (Static)
        function sim = new(name)
            %NEW Creates a new simulink block diagram.
            % Syntax:
            %   sys = simulation.new(MODEL);
            %     MODEL is the name of the simulink model to be created. If
            %     MODEL already exists an erro is thrown.

            sys = new_system(name,'ErrorIfShadowed');
            sim = matsim.library.simulation(sys);
            set_param(0,'CurrentSystem',sys)
        end
        
        function sim = load(name)
            %LOAD Creates or loads a simulink block diagram.
            % Syntax:
            %   sys = simulation.load(MODEL);
            %     MODEL is the name of the simulink model to be loaded. If MODEL does
            %     not exist, a new simulink model will be created.

            try
                sys = load_system(name);
                sim = matsim.library.simulation(sys);                
                set_param(0,'CurrentSystem',sys)
            catch
                sim = matsim.library.simulation.new(name);
            end
        end
    end
       
    methods
        function this = simulation(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            p.KeepUnmatched = true;
            addRequired(p,'sys',@ishandle);
            parse(p,varargin{:})
            
            sys = p.Results.sys;
            this.simDiagram = sys;
            
            % Set output and logging format
            set_param(this.handle,'SaveFormat','Array')
            set_param(this.handle,'SignalLoggingSaveFormat','Dataset')
        end

        function [] = setSolver(this,varargin)
            %SETSOLVER Set solver options for this model
            % Syntax:
            %   sys.setSolver('Ts',TS);
            %     Sets solver sample time. If TS~=0 a fixed step solver
            %     will be set. Otherwise "VariableStepAuto" selver will be
            %     used.
            %   sys.setSolver('Ts',TS,'DiscreteOnly',DISCRONLY);
            %     If DISCRONLY is true, "FixedStepDiscrete" solver will be
            %     used. Otherwise "FixedStepAuto" solver is set.
            
            p = inputParser;
            p.CaseSensitive = false;
            p.KeepUnmatched = true;
            addParamValue(p,'DiscreteOnly',false,@islogical);
            addParamValue(p,'Ts',0,@isnumeric);
            parse(p,varargin{:})
            
            Ts = p.Results.Ts;
            DiscreteOnly = p.Results.DiscreteOnly;
            
            if Ts ~= 0
                this.set('FixedStep',mat2str(Ts))
                if DiscreteOnly
                    this.set('SolverName','FixedStepDiscrete')
                else
                    this.set('SolverName','FixedStepAuto')
                end
            else
                this.set('SolverName','VariableStepAuto')
            end
        end
        
        function [] = show(this)
            %SHOW Shows the model window
            
            if strcmp(this.get('Shown'),'off') ...
                    || ~strcmp(bdroot, this.get('name'))
                open_system(this.handle)
            end
        end
        
        function [] = save(this,varargin)
            %SAVE Save the model to file
            % Syntax:
            %   sys.save();
            %     Save the model in the current folder.
            %   sys.save('path',PATH);
            %     Save the model in the specified path.
            
            p = inputParser;
            p.CaseSensitive = false;
            p.KeepUnmatched = true;
            addOptional(p,'path',[],@ischar);
            parse(p,varargin{:})
            
            save_system(this.handle,fullfile(p.Results.path,this.get('name')))
        end
        
        function [] = close(this)
            %CLOSE Close the model without saving
            
            if strcmp(this.get('Shown'),'off') ...
                    || strcmp(this.get('Dirty'),'off')
                close_system(this.handle,0)
            end
        end
        
        function [] = clear(this)
            %CLEAR Deletes all model content
            
            if strcmp(this.get('Shown'),'on') ...
                    && ~strcmp(gcs, this.get('name'))
                open_system(this.handle)
            end
            Simulink.BlockDiagram.deleteContents(this.handle)
        end
        
        function [] = layout(this)
            %LAYOUT Layout and connect blocks in the model
            
            matsim.builder.graphviz.simlayout(this.handle,'Recursive',true)
        end
        
        function [] = export(this)
            %EXPORT Removes all Matsim info from the model
            
            blocks = find_system(this.handle,'type','block');
            for i=1:length(blocks)
                data = get(blocks(i),'UserData');
                if isfield(data,'block'), data = rmfield(data,'block'); end
                if isfield(data,'created'), data = rmfield(data,'created'); end
                set(blocks(i),'UserData',data);
            end
        end

        function [] = open(this,varargin)
            %OPEN Navigate to specified subsystem
            % Syntax:
            %   sys.open(PATH);
            %     Navigate to the selected path in the model
            %   sys.open(PATH,'show',SHOW);
            %     If SHOW is true open the subsystem in a new tab. If false
            %     only set the "CurrentSystem" property.
            % 
            % Example:
            %   sys = simulation.load('my_model')
            %   sys.show()
            %   s = Subsystem('name','TEST');
            %   sys.open('my_model/TEST','show',true)
            
            p = inputParser;
            p.CaseSensitive = false;
            p.KeepUnmatched = true;
            addOptional(p,'subsystem',{},@(x) isempty(x) || ischar(x) || ishandle(x) || isa(x,'matsim.library.block') || isa(x,'matsim.library.simulation'));
            addParamValue(p,'show',false,@islogical)
            parse(p,varargin{:})
            
            sys = p.Results.subsystem;
            if isempty(sys)
                sys = this;
            end
            
            subsystem = matsim.helpers.getBlockPath(sys);
            if ~strcmp(gcs, subsystem)
                if p.Results.show
                    open_system(subsystem,'tab')
                else
                    set_param(0,'CurrentSystem',subsystem)
                end
            end
        end
        
        function simOut = run(this,varargin)
            %RUN Run simulation and return results
            % Syntax:
            %   results = sys.run(ARGS);
            %     ARGS are passed to simulink "sim" command
            % 
            % Example:
            %   sys = simulation.load('my_model')
            %   simOut = sys.run('StartTime',0,'StopTime',10);
            
            p = inputParser;
            p.CaseSensitive = false;
            p.KeepUnmatched = true;
            parse(p,varargin{:})
            
            args = matsim.helpers.validateArgs(p.Unmatched);
            simOut = matsim.library.simOutput(sim(this.get('name'),args{:}));
        end

        function [] = log(this,varargin)
            %LOG Log a signal
            % Syntax:
            %   results = sys.log(BLOCK);
            %     Logs first outport of BLOCK. Line label is used as signal name.
            %   results = sys.log(BLOCK,'name',MYSIGNAL);
            %     Logs first outport of BLOCK. MYSIGNAL is used as signal name.
            %   results = sys.log(BLOCK,'port',PORT);
            %     Logs PORT outport of BLOCK. PORT is integer.
            % 
            % Example:
            %   sys = simulation.load('my_model')
            %   sys.show()
            %   blk = Gain(Constant(1));
            %   blk.outport(1,'name','test_signal');
            %   Terminator(blk);
            %   sys.layout()
            %   sys.log(blk)
            %   sys.log(blk,'name','custom_name')
            
            p = inputParser;
            p.CaseSensitive = false;
            p.KeepUnmatched = true;
            addRequired(p,'block',@(x) isa(x,'matsim.library.block'))
            addParamValue(p,'name','',@ischar)
            addParamValue(p,'port',1,@isnumeric);
            parse(p,varargin{:})
            
            block = p.Results.block;
            name = p.Results.name;
            port = p.Results.port;
            
            ph = get(block,'porthandles');
            if ~isempty(name)
                set(ph.Outport(port),'DataLogging','on');
                set(ph.Outport(port),'DataLoggingNameMode','Custom');
                set(ph.Outport(port),'DataLoggingName',name);
            elseif ~isempty(get(ph.Outport(port),'SignalNameFromLabel'))
                set(ph.Outport(port),'DataLogging','on');
                set(ph.Outport(port),'DataLoggingNameMode','SignalName');
                set(ph.Outport(port),'DataLoggingName',get(ph.Outport(port),'SignalNameFromLabel'));
            elseif ~isempty(get(ph.Outport(port),'PropagatedSignals'))
                set(ph.Outport(port),'DataLogging','on');
                set(ph.Outport(port),'DataLoggingNameMode','Custom');
                set(ph.Outport(port),'DataLoggingName',get(ph.Outport(port),'PropagatedSignals'));
            else
                set(ph.Outport(port),'DataLogging','off');
                warning('MATSIM:Simulation','Cannot log this line. Specify the ''name'' parameter.')
            end
        end
        
        function h = handle(this)
            h = this.simDiagram;
        end
        function p = get(this,prop)
            p = get(this.simDiagram,prop);
        end
        function [] = set(this,prop,value)
            if iscell(prop)
                arrayfun(@(i) this.set(prop{i},prop{i+1}), 1:2:length(prop)-1)
                return
            end
            
            set(this.simDiagram,prop,value);
        end
    end
    
end
