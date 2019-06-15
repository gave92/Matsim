classdef Max < binary_operator
%MAX Creates a simulink Max block.
% Example:
%   in1 = Constant('var1');
%   in2 = Constant('var2');
%   blk = Max(in1,in2,'name','myMax');
% 
%   See also BINARY_OPERATOR.

    properties
        
    end
    
    methods
        function this = Max(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;            
            addOptional(p,'b1',{},@(x) isnumeric(x) || isempty(x) || isa(x,'block'));
            addOptional(p,'b2',{},@(x) isnumeric(x) || isempty(x) || isa(x,'block'));
            parse(p,varargin{:})
            
            b1 = p.Results.b1;
            b2 = p.Results.b2;
            args = helpers.validateArgs(p.Unmatched);
            
            this = this@binary_operator(b1,b2,'ops','MinMax','Function','Max','Inputs',mat2str(2),args{:});
        end
    end
    
end

