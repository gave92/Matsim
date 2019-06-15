classdef Cos < unary_operator
%COS Creates a simulink Cos block.
% Example:
%   input = Constant('var1');
%   blk = Cos(input,'Name','myCos');
% 
%   See also UNARY_OPERATOR.

    properties
        
    end
    
    methods
        function this = Cos(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;            
            addOptional(p,'b1',{},@(x) isnumeric(x) || isempty(x) || isa(x,'block'));
            parse(p,varargin{:})
          
            b1 = p.Results.b1;
            args = helpers.validateArgs(p.Unmatched);
            
            this = this@unary_operator(b1,'ops','Trigonometric Function','Operator','Cos',args{:});
        end
    end
    
end

