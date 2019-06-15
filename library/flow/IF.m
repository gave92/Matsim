classdef IF < Switch
%IF Creates a simulink Switch block.
% Syntax:
%   Same as Switch but Condition is first argument.
% 
% Example:
%   in1 = FromWorkspace('var1');
%   out = FromWorkspace('var2');
%   IF(in1>0,1,out);
% 
%   See also SWITCH.

    properties

    end
    
    methods
        function this = IF(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addOptional(p,'cond',{},@(x) isnumeric(x) || isempty(x) || isa(x,'block'));
            addOptional(p,'b1',{},@(x) isnumeric(x) || isempty(x) || isa(x,'block'));
            addOptional(p,'b2',{},@(x) isnumeric(x) || isempty(x) || isa(x,'block'));
            parse(p,varargin{:})
            
            b1 = p.Results.b1;
            b2 = p.Results.b2;
            cond = p.Results.cond;
            args = helpers.validateArgs(p.Unmatched);
            
            this = this@Switch(b1,b2,cond,args{:});
        end
    end
end

