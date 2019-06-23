classdef FromWorkspace < matsim.library.block        
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
            p.KeepUnmatched = true;
            addRequired(p,'VariableName',@(x) ischar(x) || isnumeric(x));
            addParamValue(p,'parent','',@(x) ischar(x) || ishandle(x) || isa(x,'matsim.library.block') || isa(x,'matsim.library.simulation'));
            parse(p,varargin{:})
            
            VariableName = p.Results.VariableName;
            parent = p.Results.parent;
            args = matsim.helpers.validateArgs(p.Unmatched);

            if isempty(parent)
                parent = gcs;
            end
            
            this = this@matsim.library.block('type','From Workspace','parent',parent,args{:});
            
            if ~isempty(VariableName)
                this.set('VariableName',VariableName)
            end
        end               
    end
end

