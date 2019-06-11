classdef Sin < matsim.library.unary_operator
%SIN Creates a simulink Sin block.
% Example:
%   input = Constant('var1');
%   blk = Sin(input,'Name','mySin');
% 
%   See also UNARY_OPERATOR.

    properties
        
    end
    
    methods
        function this = Sin(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addOptional(p,'b1',{},@(x) isnumeric(x) || isempty(x) || isa(x,'matsim.library.block'));
            parse(p,varargin{:})
            
            b1 = p.Results.b1;
            args = matsim.helpers.validateArgs(p.Unmatched);
            
            this = this@matsim.library.unary_operator(b1,'ops','Trigonometric Function','Operator','Sin',args{:});
        end
    end
    
end

