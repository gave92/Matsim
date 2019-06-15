classdef Constant < block
%CONSTANT Creates a simulink Constant block.
% Syntax:
%   blk = Constant(VALUE);
%     VALUE may be numeric or string (variable name)
%   blk = Constant(VALUE, ARGS);
%     ARGS is an optional list of parameter/value pairs specifying simulink
%     block properties.
%
% Example:
%   blk = Constant(0);
%   blk = Constant('var1','parent',gcs);
%   blk = Constant(-1,'Name','myConst','BackgroundColor','red');
% 
%   See also BLOCK.

    properties

    end
    
    methods
        function this = Constant(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addRequired(p,'value',@(x) ischar(x) || isnumeric(x));
            addParamValue(p,'parent','',@(x) ischar(x) || ishandle(x) || isa(x,'block') || isa(x,'simulation'));
            parse(p,varargin{:})
            
            value = p.Results.value;
            parent = p.Results.parent;
            args = helpers.validateArgs(p.Unmatched);
            
            this = this@block('type','Constant','parent',parent,args{:});
            this.set({'Value',value,'VectorParams1D','off'})
        end
    end
end

