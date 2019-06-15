classdef Mux < block
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
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addOptional(p,'inputs',{},@(x) isnumeric(x) || iscell(x) || isa(x,'block'));
            addParamValue(p,'parent','',@(x) ischar(x) || ishandle(x) || isa(x,'block') || isa(x,'simulation'));
            parse(p,varargin{:})
            
            inputs = p.Results.inputs;
            if ~iscell(inputs)
                inputs = {inputs};
            end
            
            parent = helpers.getValidParent(inputs{:},p.Results.parent);
            args = helpers.validateArgs(p.Unmatched);
            
            % validateattributes(parent,{'char'},{'nonempty'},'','parent')
            if isempty(parent)
                parent = gcs;
            end
            
            this = this@block('type','Mux','parent',parent,args{:});
            
            this.set('Inputs',mat2str(length(inputs)))            
            this.setInputs(inputs);
        end
    end
end

