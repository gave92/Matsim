classdef BusCreator < matsim.library.block
%BUSCREATOR Creates a simulink BusCreator block.
% Syntax:
%   blk = BusCreator(INPUTS);
%     INPUTS blocks will be connected to the block input ports.
%     INPUTS can be:
%       - an empty cell {}
%       - a matsim block
%       - a number
%       - a cell array of the above
%     If INPUTS is a number a Constant block with that value will
%     be created.
%   blk = BusCreator(INPUTS, ARGS);
%     ARGS is an optional list of parameter/value pairs specifying simulink
%     block properties.
%
% Example:
%   % Create inputs for BusCreator
%   in1 = Constant('var1');
%   in2 = Constant('var2');
%   in3 = FromWorkspace('var3');
% 
%   % Set signal names
%   in1.outport(1,'name','sig1');
%   in2.outport(1,'name','sig2');
%   in3.outport(1,'name','sig3');
% 
%   % Create block
%   blk = BusCreator({in1,in2,in3},'parent',gcs);
% 
%   See also BLOCK.

    properties

    end
    
    methods
        function this = BusCreator(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addOptional(p,'inputs',{},@(x) isnumeric(x) || iscell(x) || isa(x,'matsim.library.block'));
            addParamValue(p,'parent','',@(x) ischar(x) || ishandle(x) || isa(x,'matsim.library.block') || isa(x,'matsim.library.simulation'));
            parse(p,varargin{:})
            
            inputs = p.Results.inputs;
            if ~iscell(inputs)
                inputs = {inputs};
            end
            
            parent = matsim.helpers.getValidParent(inputs{:},p.Results.parent);
            args = matsim.helpers.validateArgs(p.Unmatched);
            
            % validateattributes(parent,{'char'},{'nonempty'},'','parent')
            if isempty(parent)
                parent = gcs;
            end
            
            this = this@matsim.library.block('type','Bus Creator','parent',parent,args{:});
                        
            if this.getUserData('created') == 0
                this.set('Inputs',mat2str(max(1,length(inputs))))
                this.setInputs(inputs);
            end
        end
    end
end

