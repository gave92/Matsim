classdef Atan < matsim.library.unary_operator
%ATAN Creates a simulink Atan block.
% Example:
%   input = Constant('var1');
%   blk = Atan(input,'Name','myAtan');
% 
%   See also UNARY_OPERATOR.

    properties
        
    end
    
    methods
        function this = Atan(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addOptional(p,'b1',{},@(x) isnumeric(x) || isempty(x) || isa(x,'matsim.library.block'));
            parse(p,varargin{:})
          
            b1 = p.Results.b1;
            args = matsim.helpers.validateArgs(p.Unmatched);
            
            this = this@matsim.library.unary_operator(b1,'ops','Trigonometric Function','Operator','Atan',args{:});
        end
    end
    
end

