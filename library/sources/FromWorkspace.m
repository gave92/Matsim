classdef FromWorkspace < block        
%FROMWORKSPACE Creates a simulink FromWorkspace block.
% Syntax:
%   blk = FromWorkspace(VARIABLENAME);
%     VARIABLENAME may be numeric or string
%   blk = FromWorkspace(VARIABLENAME, ARGS);
%     ARGS is an optional list of parameter/value pairs specifying simulink
%     block properties.
%
% Example:
%   blk = FromWorkspace('var1','parent',gcs);
%   blk = FromWorkspace('var1','Name','myVar','BackgroundColor','red');
% 
%   See also BLOCK.

    properties

    end
    
    methods
        function this = FromWorkspace(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addRequired(p,'varname',@(x) ischar(x) || isnumeric(x));
            addParamValue(p,'parent','',@(x) ischar(x) || ishandle(x) || isa(x,'block') || isa(x,'simulation'));
            parse(p,varargin{:})
            
            varname = p.Results.varname;
            parent = p.Results.parent;
            args = helpers.validateArgs(p.Unmatched);
            
            this = this@block('type','From Workspace','parent',parent,args{:});
            
            if ~isempty(varname)
                this.set('VariableName',varname)
            end
        end               
    end
end

