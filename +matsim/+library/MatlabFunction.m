classdef MatlabFunction < matsim.library.block
%MATLABFUNCTION Creates a simulink MATLAB Function block.
% Syntax:
%   blk = MatlabFunction(INPUTS);
%     INPUTS blocks will be connected to the block input ports.
%     INPUTS can be:
%       - an empty cell {}
%       - a matsim block
%       - a number
%       - a cell array of the above
%     If INPUTS is a number a Constant block with that value will
%     be created.
%   blk = MatlabFunction(INPUTS, 'Script', SCRIPT);
%     SCRIPT will be set as MATLAB Function content
%     SCRIPT can be:
%       - a file name
%       - a string (e.g 'function y = fcn(u)')
%     If SCRIPT is an existing file name, the contents of that file will be
%     read into the block.
%   blk = MatlabFunction(INPUTS, 'Script', SCRIPT, ARGS);
%     ARGS is an optional list of parameter/value pairs specifying simulink
%     block properties.
% 
% Example:
%   in1 = Constant(0);
%   in2 = FromWorkspace('var1');
%   blk = MatlabFunction({in1,in2});
%   blk.setScript('my_func.m');
%
%  MatlabFunction Methods:
%    setScript - Set MATLAB Function content
% 
%   See also BLOCK.
    
    properties (Access = private)
        % Handle to object
        chartHandle
    end
    
    methods
        function this = MatlabFunction(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addOptional(p,'inputs',{},@(x) isnumeric(x) || iscell(x) || isa(x,'matsim.library.block'));
            addParamValue(p,'Script','',@(x) ischar(x));
            addParamValue(p,'parent','',@(x) ischar(x) || ishandle(x) || isa(x,'matsim.library.block') || isa(x,'matsim.library.simulation'));
            parse(p,varargin{:})
                        
            inputs = p.Results.inputs;            
            if ~iscell(inputs)
                inputs = {inputs};
            end
            
            Script = p.Results.Script;
            parent = matsim.helpers.getValidParent(inputs{:},p.Results.parent);
            args = matsim.helpers.validateArgs(p.Unmatched);
            
            % validateattributes(parent,{'char'},{'nonempty'},'','parent')
            if isempty(parent)
                parent = gcs;
            end
            
            this = this@matsim.library.block('type','MATLAB Function','parent',parent,args{:});
            this.chartHandle = find(slroot, '-isa', 'Stateflow.EMChart', 'Path', matsim.helpers.getBlockPath(this));
            
            [~,~,ext] = fileparts(Script);
            if ~isempty(ext) && exist(Script,'file')==2
                this.chartHandle.Script = fileread(Script);
            elseif ~isempty(Script)
                this.chartHandle.Script = Script;
            elseif this.getUserData('created') == 0
                this.chartHandle.Script = sprintf('function [y] = fcn(%s)',strjoin(arrayfun(@(i) sprintf('u%d',i),1:length(inputs),'Uni',0),','));
            end

            if this.getUserData('created') == 0
                this.setInputs(inputs);
            end
        end
        
        function [] = setScript(this,Script)
            %SETSCRIPT Set MATLAB Function content
            % Syntax:
            %   m.setScript(SCRIPT)
            %     SCRIPT will be set as MATLAB Function content
            %     SCRIPT can be:
            %       - a file name
            %       - a string (e.g 'function y = fcn(u)')
            %     If SCRIPT is an existing file name, the contents of that file will be
            %     read into the block.
            %
            % Example:
            %   m = MatlabFunction(0);
            %   m.setScript('my_func.m')
            [~,~,ext] = fileparts(Script);
            if ~isempty(ext) && exist(Script,'file')==2
                this.chartHandle.Script = fileread(Script);
            else
                this.chartHandle.Script = Script;
            end
        end
    end
    
end

