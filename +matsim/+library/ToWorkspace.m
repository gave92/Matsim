classdef ToWorkspace < matsim.library.unary_operator        
%TOWORKSPACE Creates a simulink ToWorkspace block.
% Syntax:
%   blk = ToWorkspace(INPUT,'VariableName',VARIABLENAME);
%     VARIABLENAME may be numeric or string
%   blk = ToWorkspace(INPUT,'VariableName',VARIABLENAME,ARGS);
%     ARGS is an optional list of parameter/value pairs specifying simulink
%     block properties.
%
% Example:
%   in1 = Constant('var1');
%   blk = ToWorkspace(in1,'VariableName','varOut','parent',gcs);
%   blk = ToWorkspace(in1,'VariableName','varOut2','Name','myVar','BackgroundColor','red');
% 
%   See also UNARY_OPERATOR.

    properties

    end
    
    methods
        function this = ToWorkspace(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            p.KeepUnmatched = true;
            addOptional(p,'b1',[],@(x) isnumeric(x) || isempty(x) || isa(x,'matsim.library.block'));
            addParamValue(p,'VariableName','',@(x) ischar(x) || isnumeric(x));
            parse(p,varargin{:})
            
            b1 = p.Results.b1;
            VariableName = p.Results.VariableName;
            args = matsim.helpers.validateArgs(p.Unmatched);
            
            this = this@matsim.library.unary_operator(b1,'BlockName','To Workspace',args{:});
            
            if ~isempty(VariableName)
                this.set('VariableName',VariableName)
            end            
        end               
    end
end

