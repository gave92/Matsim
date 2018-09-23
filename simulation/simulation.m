classdef simulation < handle
    properties (Access = private)
        % Handle to simulink system
        simDiagram
    end
    
    methods (Static)
        function sim = new(name)
            sys = new_system(name,'ErrorIfShadowed');
            sim = simulation(sys);
        end
        
        function sim = load(name)
            try
                sys = load_system(name);
                sim = simulation(sys);
            catch
                sim = simulation.new(name);
            end
        end
    end
       
    methods
        function this = simulation(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
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
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
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
            if strcmp(this.get('Shown'),'off') ...
                    || ~strcmp(bdroot, this.get('name'))
                open_system(this.handle,'tab')
            end
        end
        
        function [] = save(this,varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addOptional(p,'path',[],@ischar);
            parse(p,varargin{:})
            
            save_system(this.handle,fullfile(p.Results.path,this.get('name')))
        end
        
        function [] = close(this)
            % Close model without saving
            if strcmp(this.get('Shown'),'off')
                close_system(this.handle,0)
            end
        end
        
        function [] = clear(this)
            if strcmp(this.get('Shown'),'on') ...
                    && ~strcmp(gcs, this.get('name'))
                open_system(this.handle,'tab')
            end
            Simulink.BlockDiagram.deleteContents(this.handle)
        end
        
        function [] = open(this,varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addOptional(p,'subsystem',[],@(x) ischar(x) || ishandle(x) || isa(x,'block') || isa(x,'simulation'));
            addParamValue(p,'show',false,@islogical)
            parse(p,varargin{:})
            
            sys = p.Results.subsystem;
            if isempty(sys)
                sys = this;
            end
            
            subsystem = helpers.getBlockPath(sys);
            if ~strcmp(gcs, subsystem)
                if p.Results.show
                    open_system(subsystem,'tab')
                else
                    set_param(0,'CurrentSystem',subsystem)
                end
            end
        end
        
        function simOut = run(this,varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            parse(p,varargin{:})
            
            args = helpers.validateArgs(p.Unmatched);
            simOut = simOutput(sim(this.get('name'),args{:}));
        end

        function [] = log(this,varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addRequired(p,'block',@(x) isa(x,'block'))
            addRequired(p,'name',@ischar)
            addParamValue(p,'port',1,@isnumeric);
            parse(p,varargin{:})
            
            block = p.Results.block;
            name = p.Results.name;
            port = p.Results.port;
            
            ph = get(block,'porthandles');
            set(ph.Outport(port),'DataLogging','on');
            set(ph.Outport(port),'DataLoggingNameMode','Custom');
            set(ph.Outport(port),'DataLoggingName',name);
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
