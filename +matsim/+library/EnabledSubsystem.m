function blk = EnabledSubsystem(varargin)
%SUBSYSTEM Creates a simulink Subsystem block with enable port.
% Syntax:
%  Same as Subsystem.
% 
% Example:
%   in1 = Constant('var1');
%   en = Delay(Constant(1));
%   s = EnabledSubsystem({in1},'Enable',en); % Subsystem with one inport
% 
%   See also Subsystem.

    p = inputParser;
    p.CaseSensitive = false;
    p.KeepUnmatched = true;
    addOptional(p,'inputs',[],@(x) isnumeric(x) || iscell(x) || isa(x,'matsim.library.block'));
    addParamValue(p,'Enable',[],@(x) isnumeric(x) || isempty(x) || isa(x,'matsim.library.block'));
    parse(p,varargin{:})

    inputs = p.Results.inputs;
    enable = p.Results.Enable;
    args = matsim.helpers.unpack(p.Unmatched);

    blk = matsim.library.Subsystem(inputs,args{:});
    ports = blk.getPorts();
    
    if matsim.helpers.isArgSpecified(p,'Enable') || isempty(ports.enable)
        blk.enable(enable);
    end
end
