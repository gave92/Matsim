classdef Integrator < matsim.library.unary_operator
    properties
        
    end
    
    methods
        function this = Integrator(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;            
            addOptional(p,'b1',{},@(x) isnumeric(x) || isempty(x) || isa(x,'matsim.library.block'));
            addParamValue(p,'SampleTime',0,@isnumeric);
            addParamValue(p,'x0',0,@isnumeric);
            parse(p,varargin{:})
            
            b1 = p.Results.b1;
            SampleTime = p.Results.SampleTime;
            x0 = p.Results.x0;
            args = matsim.helpers.validateArgs(p.Unmatched);
            
            if SampleTime ~= 0
                integ = 'Discrete-Time Integrator';
            else
                integ = 'Integrator';
            end
            
            this = this@matsim.library.unary_operator(b1,'ops',integ,args{:});
            this.set('InitialCondition',mat2str(x0));
            if SampleTime ~= 0
                this.set('SampleTime',mat2str(SampleTime));
            end
        end
    end
    
end

