classdef Mux < matsim.library.block
%MUX Creates a simulink Mux block.
% Syntax:
%   blk = Mux(INPUTS);
%     INPUTS blocks will be connected to the block input ports.
%     INPUTS can be:
%       - an empty cell {}
%       - a matsim block
%       - a number
%       - a cell array of the above
%     If INPUTS is a number a Constant block with that value will
%     be created.
%   blk = Mux(INPUTS, ARGS);
%     ARGS is an optional list of parameter/value pairs specifying simulink
%     block properties.
%
% Example:
%   in1 = Constant(0);
%   in2 = FromWorkspace('var1');
%   in3 = FromWorkspace('var2');
%   blk1 = Mux({in1,in2,in3});
%   blk2 = [in1,in2,in3];
% 
%   See also BLOCK.

    properties

    end
    
    methods
        function this = Mux(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            p.KeepUnmatched = true;
            addOptional(p,'inputs',[],@(x) isnumeric(x) || iscell(x) || isa(x,'matsim.library.block'));
            addParamValue(p,'parent','',@(x) ischar(x) || ishandle(x) || isa(x,'matsim.library.block') || isa(x,'matsim.library.simulation'));
            parse(p,varargin{:})
            
            inputs = p.Results.inputs;
            if ~iscell(inputs)
                inputs = {inputs};
            end
            
            parent = matsim.helpers.getValidParent(inputs{:},p.Results.parent);
            args = matsim.helpers.validateArgs(p.Unmatched);
            
            if isempty(parent)
                parent = gcs;
            end
            
            this = this@matsim.library.block('BlockType','Mux','parent',parent,args{:});

            if matsim.helpers.isArgSpecified(p,'inputs')
                this.set('Inputs',mat2str(max(1,length(inputs))))
                this.setInputs(inputs);
            end
        end
    end
end
