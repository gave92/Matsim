classdef binary_operator < block
%BINARY_OPERATOR Creates a simulink block with two inputs.
% Syntax:
%   blk = binary_operator('ops',OPERATOR);
%     OPERATOR is a string. Must match the name ("BlockName") of a block in
%     the simulink library.
%   blk = binary_operator(IN1,IN2,'ops',OPERATOR);
%     The block specified as IN1 will be connected to the first input port of this block.
%     The block specified as IN2 will be connected to the second input port of this block.
%     IN1 and IN2 can be:
%       - an empty cell {}
%       - a Matsim block
%       - a number/numeric array
%   blk = binary_operator(IN1,IN2,'ops',OPERATOR,ARGS);
%     ARGS is an optional list of parameter/value pairs specifying simulink
%     block properties.
%
% Example:
%   in1 = Constant('var1');
%   blk = binary_operator(in1,-1,'ops','2-D Lookup Table');
% 
%   See also BLOCK.

    properties

    end
    
    methods
        function this = binary_operator(varargin)
            p = inputParser;
            p.CaseSensitive = true;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addOptional(p,'b1',{},@(x) isnumeric(x) || isempty(x) || isa(x,'block'));
            addOptional(p,'b2',{},@(x) isnumeric(x) || isempty(x) || isa(x,'block'));
            addParamValue(p,'ops','',@ischar);
            addParamValue(p,'parent','',@(x) ischar(x) || ishandle(x) || isa(x,'block') || isa(x,'simulation'));
            parse(p,varargin{:})
            
            inputs = {p.Results.b1,p.Results.b2};
            ops = p.Results.ops;
            parent = helpers.getValidParent(inputs{:},p.Results.parent);
            args = helpers.validateArgs(p.Unmatched);
            
            % validateattributes(parent,{'char'},{'nonempty'},'','parent')
            if isempty(parent)
                parent = gcs;
            end
            if isempty(ops)
                error('Invalid operator.')
            end
                        
            this = this@block('type',ops,'parent',parent,args{:});
            this.setInputs(inputs);
        end
    end
end

