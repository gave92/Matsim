classdef Delay < matsim.library.unary_operator
%DELAY Creates a simulink Delay block.
% Syntax:
%   blk = Delay(INPUT,'DelayLength',DELAYLENGTH,'x0',X0);
%     The block specified as INPUT will be connected to the input port of this block.
%     DELAYLENGTH is an integer specifying the number of delay steps. If 1
%     a "Unit Delay" block will be used, if greater than 1 the "Delay"
%     simulink block will be used.
%     X0 is a number that will be set as block's Initial Condition.
%
% Example:
%   in1 = FromWorkspace('var1');
%   blk = Delay(in1,'DelayLength',2,'x0',0);
% 
%   See also UNARY_OPERATOR.

    properties
        
    end
    
    methods
        function this = Delay(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            p.KeepUnmatched = true;
            addOptional(p,'b1',[],@(x) isnumeric(x) || isempty(x) || isa(x,'matsim.library.block'));
            addParamValue(p,'DelayLength',1,@isnumeric);
            addParamValue(p,'SampleTime',-1,@isnumeric);
            addParamValue(p,'x0',0,@isnumeric);
            parse(p,varargin{:})

            b1 = p.Results.b1;
            DelayLength = p.Results.DelayLength;
            SampleTime = p.Results.SampleTime;
            x0 = p.Results.x0;
            args = matsim.helpers.validateArgs(p.Unmatched);
            
            if DelayLength ~= 1
                dl = 'Delay';
            else
                dl = 'Unit Delay';
            end
            
            this = this@matsim.library.unary_operator(b1,'BlockName',dl,args{:});
            this.set('SampleTime',mat2str(SampleTime))
            if matsim.utils.getversion() < 2014 && strcmp(dl, 'Unit Delay')
                this.set('X0',mat2str(x0))
            else
                this.set('InitialCondition',mat2str(x0))
            end
            if DelayLength ~= 1
                this.set('DelayLength',mat2str(DelayLength))
            end
        end
    end
    
end

