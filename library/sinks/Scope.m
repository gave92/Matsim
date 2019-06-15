classdef Scope < block
%SCOPE Creates a simulink Scope block.
% Syntax:
%   blk = Scope(INPUTS);
%     INPUTS blocks will be connected to the block input ports.
%     INPUTS can be:
%       - an empty cell {}
%       - a matsim block
%       - a number
%       - a cell array of the above
%     If INPUTS is a number a Constant block with that value will
%     be created.
%   blk = Scope(INPUTS, ARGS);
%     ARGS is an optional list of parameter/value pairs specifying simulink
%     block properties.
%
% Example:
%   in1 = Constant(0);
%   in2 = FromWorkspace('var1');
%   in3 = FromWorkspace('var2');
%   blk = Scope({[in1,in2],in3});
% 
%  Scope Methods:
%    open - Open the Scope window
% 
%   See also BLOCK.

    properties

    end
    
    methods
        function this = Scope(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addOptional(p,'inputs',{},@(x) isnumeric(x) || iscell(x) || isa(x,'block'));
            addParamValue(p,'numPorts',1,@isnumeric);
            addParamValue(p,'parent','',@(x) ischar(x) || ishandle(x) || isa(x,'block') || isa(x,'simulation'));
            parse(p,varargin{:})
            
            inputs = p.Results.inputs;
            if ~iscell(inputs)
                inputs = {inputs};
            end
            
            parent = helpers.getValidParent(inputs{:},p.Results.parent);
            numPorts = p.Results.numPorts;
            args = helpers.validateArgs(p.Unmatched);
            
            if isempty(parent)
                parent = gcs;
            end
            
            this = this@block('type','Scope','parent',parent,args{:});
            
            if getversion() >= 2015
                scope_configuration = this.get('ScopeConfiguration');
                scope_configuration.NumInputPorts = mat2str(max(numPorts,length(inputs)));
                scope_configuration.LayoutDimensions = [max(numPorts,length(inputs)), 1]; % Rows, columns
            else
                this.set('NumInputPorts',mat2str(max(numPorts,length(inputs))));
            end

            this.setInputs(inputs);
        end
        
        function [] = open(this)
            %OPEN Open the Scope window
            % Example:
            %   blk = Scope({{}});
            %   blk.open()

            set_param(this.handle,'open','on');
        end
    end
end

