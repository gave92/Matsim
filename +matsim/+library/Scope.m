classdef Scope < matsim.library.block
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
%    close - Close the Scope window
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
            addOptional(p,'inputs',{},@(x) isnumeric(x) || iscell(x) || isa(x,'matsim.library.block'));
            addParamValue(p,'parent','',@(x) ischar(x) || ishandle(x) || isa(x,'matsim.library.block') || isa(x,'matsim.library.simulation'));
            parse(p,varargin{:})
            
            inputs = p.Results.inputs;
            if ~iscell(inputs)
                inputs = {inputs};
            end
            
            parent = matsim.helpers.getValidParent(inputs{:},p.Results.parent);
            args = matsim.helpers.validateArgs(p.Unmatched);
            
            if isempty(parent)
                parent = gcs;
            end
            
            this = this@matsim.library.block('type','Scope','parent',parent,args{:});

            if this.getUserData('created') == 0
                if matsim.utils.getversion() >= 2015
                    scope_configuration = this.get('ScopeConfiguration');
                    scope_configuration.NumInputPorts = mat2str(max(1,length(inputs)));
                    scope_configuration.LayoutDimensions = [max(1,length(inputs)), 1]; % Rows, columns
                else
                    this.set('NumInputPorts',mat2str(max(1,length(inputs))));
                end

                this.setInputs(inputs);
            end
        end
        
        function [] = open(this)
            %OPEN Open the Scope window
            % Example:
            %   blk = Scope({{}});
            %   blk.open()
            set_param(this.handle,'open','on');
        end
        
        function [] = close(this)
            %CLOSE Close the Scope window
            % Example:
            %   blk = Scope({{}});
            %   blk.close()
            set_param(this.handle,'open','off');
        end
    end
end

