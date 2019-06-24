classdef binary_operator < matsim.library.block
%BINARY_OPERATOR Creates a simulink block with two inputs.
% Syntax:
%   blk = binary_operator('BlockName',OPERATOR);
%     OPERATOR is a string. Must match the name (prop: "BlockName") of a block in
%     the simulink library.
%   blk = binary_operator(IN1,IN2,'BlockName',OPERATOR);
%     The block specified as IN1 will be connected to the first input port of this block.
%     The block specified as IN2 will be connected to the second input port of this block.
%     IN1 and IN2 can be:
%       - an empty cell {}
%       - a Matsim block
%       - a number/numeric array
%   blk = binary_operator(IN1,IN2,'BlockName',OPERATOR,ARGS);
%     ARGS is an optional list of parameter/value pairs specifying simulink
%     block properties.
%
% Example:
%   in1 = Constant('var1');
%   blk = binary_operator(in1,-1,'BlockName','2-D Lookup Table');
% 
%   See also BLOCK.

    properties

    end
    
    methods
        function this = binary_operator(varargin)
            p = inputParser;
            p.CaseSensitive = true;
            p.KeepUnmatched = true;
            addOptional(p,'b1',[],@(x) isnumeric(x) || isempty(x) || isa(x,'matsim.library.block'));
            addOptional(p,'b2',[],@(x) isnumeric(x) || isempty(x) || isa(x,'matsim.library.block'));
            addParamValue(p,'parent','',@(x) ischar(x) || ishandle(x) || isa(x,'matsim.library.block') || isa(x,'matsim.library.simulation'));
            parse(p,varargin{:})
            
            inputs = {p.Results.b1,p.Results.b2};
            parent = matsim.helpers.getValidParent(inputs{:},p.Results.parent);
            args = matsim.helpers.validateArgs(p.Unmatched);
            
            if isempty(parent)
                parent = gcs;
            end

            this = this@matsim.library.block('parent',parent,args{:});
            if matsim.helpers.isArgSpecified(p,'b1')
                this.setInputs(inputs);
            end
        end
    end
end

