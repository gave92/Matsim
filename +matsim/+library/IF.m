classdef IF < matsim.library.Switch
    %IF Same as switch
    %   Condition is first argument    
    properties

    end
    
    methods
        function this = IF(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addOptional(p,'cond',{},@(x) isnumeric(x) || isempty(x) || isa(x,'matsim.library.block'));
            addOptional(p,'b1',{},@(x) isnumeric(x) || isempty(x) || isa(x,'matsim.library.block'));
            addOptional(p,'b2',{},@(x) isnumeric(x) || isempty(x) || isa(x,'matsim.library.block'));
            parse(p,varargin{:})
            
            b1 = p.Results.b1;
            b2 = p.Results.b2;
            cond = p.Results.cond;
            args = matsim.helpers.validateArgs(p.Unmatched);
            
            this = this@matsim.library.Switch(b1,b2,cond,args{:});
        end
    end
end

