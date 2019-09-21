function blk = ToWorkspace(varargin)
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

    blk = matsim.library.unary_operator(varargin{:},'BlockName','To Workspace');
end
