classdef Tan < matsim.library.unary_operator
%TAN Creates a simulink Tan block.
% Example:
%   input = Constant('var1');
%   blk = Tan(input,'Name','myTan');
% 
%   See also UNARY_OPERATOR.

    properties
        
    end
    
    methods
        function this = Tan(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addOptional(p,'b1',{},@(x) isnumeric(x) || isempty(x) || isa(x,'matsim.library.block'));
            parse(p,varargin{:})
          
            b1 = p.Results.b1;
            args = matsim.helpers.validateArgs(p.Unmatched);
            
            this = this@matsim.library.unary_operator(b1,'ops','Trigonometric Function','Operator','Tan',args{:});
        end
    end
    
end

