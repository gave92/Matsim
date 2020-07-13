classdef MultiPortSwitch < matsim.library.block
%MULTIPORTSWITCH Creates a simulink MultiPortSwitch block.
% Syntax:
%   blk = MultiPortSwitch(IN1,CASES);
%     IN1 block will be connected to the block first input port.
%     IN1 can be:
%       - an empty cell {}
%       - a matsim block
%       - a number
%     If IN1 is a number a Constant block with that value will
%     be created.
%     CASES blocks will be connected to the block other input ports
%     CASES can be:
%       - an empty cell {}
%       - a matsim block
%       - a number
%       - a cell array of the above
%     If CASES is a number a Constant block with that value will
%     be created.
% 
% Example:
%   in1 = FromWorkspace('var1');
%   in2 = FromWorkspace('var2');
%   in3 = FromWorkspace('var2');
%   blk = MultiPortSwitch(in1,{in2,in3});
% 
%   See also BLOCK.

    properties

    end
    
    methods
        function this = MultiPortSwitch(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            p.KeepUnmatched = true;
            addOptional(p,'b1',[],@(x) isnumeric(x) || isempty(x) || isa(x,'matsim.library.block'));
            addOptional(p,'cases',[],@(x) isnumeric(x) || iscell(x) || isa(x,'matsim.library.block'));
            addParamValue(p,'parent','',@(x) ischar(x) || ishandle(x) || isa(x,'matsim.library.block') || isa(x,'matsim.library.simulation'));
            parse(p,varargin{:})
            
            b1 = p.Results.b1;
            cases = p.Results.cases;
            if ~iscell(cases)
                cases = {cases};
            end
            
            inputs = [{b1}, cases];
            parent = matsim.helpers.getValidParent(inputs{:},p.Results.parent);
            args = matsim.helpers.validateArgs(p.Unmatched);
            
            if isempty(parent)
                parent = gcs;
            end
            
            this = this@matsim.library.block('BlockType','MultiPortSwitch','parent',parent,args{:});

            if matsim.helpers.isArgSpecified(p,'b1')
                this.setInput(1,'value',b1)
            end
            if matsim.helpers.isArgSpecified(p,'cases')
                this.set('Inputs',mat2str(max(1,length(cases))));
                for ii = 1:numel(cases)
                    this.setInput(1+ii,'value',cases{ii})
                end
            end
        end
    end
end
