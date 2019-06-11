classdef Sign < matsim.library.unary_operator
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
            addOptional(p,'b1',{},@(x) isnumeric(x) || isempty(x) || isa(x,'matsim.library.block'));
            parse(p,varargin{:})
            
            b1 = p.Results.b1;
            args = matsim.helpers.validateArgs(p.Unmatched);
            
            this = this@matsim.library.unary_operator(b1,'ops','Sign',args{:});
        end
    end
    
end

