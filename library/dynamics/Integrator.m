classdef Integrator < unary_operator
    properties
        
    end
    
    methods
        function this = Integrator(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;            
            addOptional(p,'b1',{},@(x) isnumeric(x) || isempty(x) || isa(x,'block') || isa(x,'block_input'));
            addParamValue(p,'Ts',0,@isnumeric);
            addParamValue(p,'x0',0,@isnumeric);
            parse(p,varargin{:})
            
            b1 = p.Results.b1;
            Ts = p.Results.Ts;
            x0 = p.Results.x0;
            args = helpers.validateArgs(p.Unmatched);
            
            if Ts ~= 0
                integ = 'Discrete-Time Integrator';
            else
                integ = 'Integrator';
            end
            
            this = this@unary_operator(b1,'ops',integ,args{:});
            this.set('InitialCondition',mat2str(x0));
            if Ts ~= 0
                this.set('SampleTime',mat2str(Ts));
            end
        end
    end
    
end

