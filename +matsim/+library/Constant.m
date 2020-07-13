classdef Constant < matsim.library.block
%CONSTANT Creates a simulink Constant block.
% Syntax:
%   blk = Constant(VALUE);
%     VALUE may be numeric or string (variable name)
%   blk = Constant(VALUE,ARGS);
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
            p.KeepUnmatched = true;
            addRequired(p,'Value',@(x) ischar(x) || isnumeric(x));
            addParamValue(p,'FitSize',false,@(x) islogical(x));
            addParamValue(p,'parent','',@(x) ischar(x) || ishandle(x) || isa(x,'matsim.library.block') || isa(x,'matsim.library.simulation'));
            parse(p,varargin{:})
            
            Value = p.Results.Value;
            FitSize = p.Results.FitSize;
            parent = p.Results.parent;
            args = matsim.helpers.validateArgs(p.Unmatched);
            
            if isempty(parent)
                parent = gcs;
            end
            
            this = this@matsim.library.block('BlockType','Constant','parent',parent,args{:});
            if ~isempty(Value)
                this.set({'Value',Value,'VectorParams1D','off'})
                if FitSize
                    location = this.get('Position');
                    location(3) = location(1)+max(40,10*length(Value));
                    this.set('Position',location);
                end
            end
        end
    end
end
