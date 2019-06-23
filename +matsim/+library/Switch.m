classdef Switch < matsim.library.block
%SWITCH Creates a simulink Switch block.
% Syntax:
%   blk = Switch(IN1,COND,IN2);
%     IN1 block will be connected to the block first input port.
%     COND block will be connected to the block second input port
%     (condition port).
%     IN2 block will be connected to the block third input port.
%     IN1, IN2 and COND can be:
%       - an empty cell {}
%       - a matsim block
%       - a number
%     If IN1, IN2 or COND is a number a Constant block with that value will
%     be created.
%   blk = Switch(IN1,COND,IN2, ARGS);
%     ARGS is an optional list of parameter/value pairs specifying simulink
%     block properties.
% 
% Example:
%   in1 = FromWorkspace('var1');
%   out = FromWorkspace('var2');
%   Switch(1,in1>0,out);
% 
%   See also BLOCK.

    properties

    end
    
    methods
        function this = Switch(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            p.KeepUnmatched = true;
            addOptional(p,'b1',[],@(x) isnumeric(x) || isempty(x) || isa(x,'matsim.library.block'));
            addOptional(p,'b2',[],@(x) isnumeric(x) || isempty(x) || isa(x,'matsim.library.block'));
            addOptional(p,'cond',[],@(x) isnumeric(x) || isempty(x) || isa(x,'matsim.library.block'));
            addParamValue(p,'parent','',@(x) ischar(x) || ishandle(x) || isa(x,'matsim.library.block') || isa(x,'matsim.library.simulation'));
            parse(p,varargin{:})
            
            inputs = {p.Results.b1,p.Results.cond,p.Results.b2};
            parent = matsim.helpers.getValidParent(inputs{:},p.Results.parent);
            args = matsim.helpers.validateArgs(p.Unmatched);
            
            if isempty(parent)
                parent = gcs;
            end
            
            this = this@matsim.library.block('type','Switch','parent',parent,args{:});            
            if matsim.helpers.isArgSpecified(p,'b1')
                this.set('Criteria','u2 ~= 0')
                this.setInputs(inputs);
            end
        end
    end
end

