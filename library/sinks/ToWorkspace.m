classdef ToWorkspace < unary_operator        
%TOWORKSPACE Creates a simulink ToWorkspace block.
% Syntax:
%   blk = ToWorkspace(INPUT,'varname',VARIABLENAME);
%     VARIABLENAME may be numeric or string
%   blk = ToWorkspace(INPUT,'varname',VARIABLENAME,ARGS);
%     ARGS is an optional list of parameter/value pairs specifying simulink
%     block properties.
%
% Example:
%   in1 = Constant('var1');
%   blk = ToWorkspace(in1,'varname','varOut','parent',gcs);
%   blk = ToWorkspace(in1,'varname','varOut2','Name','myVar','BackgroundColor','red');
% 
%   See also UNARY_OPERATOR.

    properties

    end
    
    methods
        function this = ToWorkspace(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addOptional(p,'b1',{},@(x) isnumeric(x) || isempty(x) || isa(x,'block'));
            addParamValue(p,'varname','',@(x) ischar(x) || isnumeric(x));
            parse(p,varargin{:})
            
            b1 = p.Results.b1;
            varname = p.Results.varname;            
            args = helpers.validateArgs(p.Unmatched);
            
            this = this@unary_operator(b1,'ops','To Workspace',args{:});
            
            if ~isempty(varname)
                this.set('VariableName',varname)
            end            
        end               
    end
end

