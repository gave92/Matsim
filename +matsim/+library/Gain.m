classdef Gain < matsim.library.unary_operator
%GAIN Creates a simulink Gain block.
% Syntax:
%   blk = Gain(INPUT,'Gain',GAIN);
%     The block specified as INPUT will be connected to the input port of this block.
%     GAIN can be number or string (variable name)
%
% Example:
%   in1 = Constant('var1');
%   blk = Gain(in1,'Gain','Mass');
%   blk = Gain(in1,'Gain',0.5);
% 
%   See also UNARY_OPERATOR.

    properties
        
    end
    
    methods
        function this = Gain(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            p.KeepUnmatched = true;
            addOptional(p,'b1',[],@(x) isnumeric(x) || isempty(x) || isa(x,'matsim.library.block'));
            addParamValue(p,'Gain',{},@(x) ischar(x) || isnumeric(x));
            parse(p,varargin{:})
            
            b1 = p.Results.b1;
            Gain = p.Results.Gain;
            args = matsim.helpers.validateArgs(p.Unmatched);
            
            this = this@matsim.library.unary_operator(b1,'BlockName','Gain',args{:});
            if ~isempty(Gain)
                this.set('Gain',Gain)
            end
        end
    end
    
end

