classdef Sign < unary_operator
%SIGN Creates a simulink Sign block.
% Example:
%   input = Constant('var1');
%   blk = Sign(input,'Name','mySign');
% 
%   See also UNARY_OPERATOR.

    properties
        
    end
    
    methods
        function this = Sign(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;            
            addOptional(p,'b1',{},@(x) isnumeric(x) || isempty(x) || isa(x,'block'));
            parse(p,varargin{:})
            
            b1 = p.Results.b1;
            args = helpers.validateArgs(p.Unmatched);
            
            this = this@unary_operator(b1,'ops','Sign',args{:});
        end
    end
    
end

