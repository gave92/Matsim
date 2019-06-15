classdef Gain < unary_operator
%GAIN Creates a simulink Gain block.
% Syntax:
%   blk = Gain(INPUT,'value',GAIN);
%     The block specified as INPUT will be connected to the input port of this block.
%     GAIN can be number or string (variable name)
%
% Example:
%   in1 = Constant('var1');
%   blk = Gain(in1,'value','Mass');
%   blk = Gain(in1,'value',0.5);
% 
%   See also UNARY_OPERATOR.

    properties
        
    end
    
    methods
        function this = Gain(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;            
            addOptional(p,'b1',{},@(x) isnumeric(x) || isempty(x) || isa(x,'block'));
            addParamValue(p,'value',{},@(x) ischar(x) || isnumeric(x));
            parse(p,varargin{:})
            
            b1 = p.Results.b1;
            value = p.Results.value;
            args = helpers.validateArgs(p.Unmatched);
            
            this = this@unary_operator(b1,'ops','Gain',args{:});
            this.set('Gain',value)
        end
    end
    
end

