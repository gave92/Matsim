classdef SwitchCase < matsim.library.unary_operator        
%SWITCHCASE Creates a simulink SwitchCase block.
% Syntax:
%   blk = SwitchCase(INPUT,'CaseConditions',CONDITIONS);
%     CONDITIONS must be a cell array containing numeric arrays
%   blk = SwitchCase(INPUT,'CaseConditions',CONDITIONS,ARGS);
%     ARGS is an optional list of parameter/value pairs specifying simulink
%     block properties.
%
% Example:
%   in1 = Constant('var1');
%   blk = SwitchCase(in1,'CaseConditions',{1,[2,3]});
% 
%   See also UNARY_OPERATOR.

    properties

    end
    
    methods
        function this = SwitchCase(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            p.KeepUnmatched = true;
            addOptional(p,'b1',[],@(x) isnumeric(x) || isempty(x) || isa(x,'matsim.library.block'));
            addParamValue(p,'CaseConditions',{},@(x) iscell(x) || isnumeric(x));
            parse(p,varargin{:})
            
            b1 = p.Results.b1;
            CaseConditions = p.Results.CaseConditions;
            args = matsim.helpers.validateArgs(p.Unmatched);
            
            this = this@matsim.library.unary_operator(b1,'ops','Switch Case',args{:});
            
            if ~isempty(CaseConditions)
                if ~iscell(CaseConditions), CaseConditions={CaseConditions}; end
                this.set('CaseConditions',matsim.utils.cell2str(CaseConditions))
            end            
        end
    end
end

