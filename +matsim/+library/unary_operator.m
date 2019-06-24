classdef unary_operator < matsim.library.block
%UNARY_OPERATOR Creates a simulink block with one input.
% Syntax:
%   blk = unary_operator('ops',OPERATOR);
%     OPERATOR is a string. Must match the name ("BlockName") of a block in
%     the simulink library.
%   blk = unary_operator(INPUT,'ops',OPERATOR);
%     The block specified as INPUT will be connected to the input port of this block.
%     INPUT can be:
%       - an empty cell {}
%       - a Matsim block
%       - a number/numeric array
%   blk = unary_operator(INPUT,'ops',OPERATOR,ARGS);
%     ARGS is an optional list of parameter/value pairs specifying simulink
%     block properties.
%
% Example:
%   input = Constant('var1');
%   blk = unary_operator(input,'ops','Trigonometric Function');
% 
%   See also BLOCK.

    properties

    end
    
    methods
        function this = unary_operator(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            p.KeepUnmatched = true;
            addOptional(p,'b1',[],@(x) isnumeric(x) || isempty(x) || isa(x,'matsim.library.block'));
            addParamValue(p,'ops','',@ischar);
            addParamValue(p,'parent','',@(x) ischar(x) || ishandle(x) || isa(x,'matsim.library.block') || isa(x,'matsim.library.simulation'));
            parse(p,varargin{:})
            
            inputs = {p.Results.b1};
            ops = p.Results.ops;
            parent = matsim.helpers.getValidParent(inputs{:},p.Results.parent);
            args = matsim.helpers.validateArgs(p.Unmatched);
            
            if isempty(parent)
                parent = gcs;
            end
            if isempty(ops)
                error('Invalid operator.')
            end
            
            this = this@matsim.library.block('BlockName',ops,'parent',parent,args{:});
            if matsim.helpers.isArgSpecified(p,'b1')
                this.setInputs(inputs);
            end
        end
    end
end

