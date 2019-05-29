classdef simOutput < handle
    properties (Access = private)
        simOut
    end
    
    methods
        function this = simOutput(simOut)
            this.simOut = simOut;
        end
        
        function out = Raw(this)
            out = this.simOut;
        end
        
        function logsOut = Logs(this)
            % Return logged data as struct
            logsOut = struct;
            log = get(this.simOut,'logsout');
            if ~isempty(log)
                for e = 1:log.getLength
                    name = log.get(e).Name;
                    logsOut.(genvarname(name)) = eval('log.get(e).Values');
                    logsOut.(genvarname(name)).Name = name;
                end
            end
        end
    end
    
end

