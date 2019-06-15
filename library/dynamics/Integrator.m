classdef Integrator < unary_operator
%INTEGRATOR Creates a simulink Integrator block.
% Syntax:
%   blk = Integrator(INPUT,'Ts',SAMPLETIME,'x0',X0);
%     The block specified as INPUT will be connected to the input port of
%     this block.
%     SAMPLETIME is optional (integer). If the SampleTime is specified a
%     "Discrete-Time Integrator" will be created, otherwise an "Integrator"
%     block will be created.
%     X0 is a number that will be set as block's Initial Condition.
%
% Example:
%   in1 = FromWorkspace('var1');
%   blk = Integrator(in1,'Ts',-1,'x0',0);
% 
%   See also UNARY_OPERATOR.

    properties
        
    end
    
    methods
        function this = Integrator(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;            
            addOptional(p,'b1',{},@(x) isnumeric(x) || isempty(x) || isa(x,'block'));
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

