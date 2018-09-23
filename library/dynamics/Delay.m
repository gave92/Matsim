classdef Delay < unary_operator
    properties
        
    end
    
    methods
        function this = Delay(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;            
            addOptional(p,'b1',{},@(x) isnumeric(x) || isempty(x) || isa(x,'block') || isa(x,'block_input'));
            addOptional(p,'DelayLength',1,@isnumeric);
            addParamValue(p,'Ts',-1,@isnumeric);
            addParamValue(p,'x0',0,@isnumeric);
            parse(p,varargin{:})
            
            b1 = p.Results.b1;
            DelayLength = p.Results.DelayLength;
            Ts = p.Results.Ts;
            x0 = p.Results.x0;
            args = helpers.validateArgs(p.Unmatched);
            
            if DelayLength ~= 1
                dl = 'Delay';
            else
                dl = 'Unit Delay';
            end
            
            this = this@unary_operator(b1,'ops',dl,args{:});            
            this.set('SampleTime',mat2str(Ts))
            if getversion() >= 2014
                this.set('InitialCondition',mat2str(x0))
            else
                this.set('X0',mat2str(x0))
            end
            if DelayLength ~= 1
                this.set('DelayLength',mat2str(DelayLength))
            end
        end
    end
    
end

