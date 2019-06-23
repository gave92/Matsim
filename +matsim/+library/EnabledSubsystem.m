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
    addParamValue(p,'Enable',{},@(x) isnumeric(x) || isempty(x) || isa(x,'matsim.library.block'));
    parse(p,varargin{:})

    enable = p.Results.Enable;
    args = matsim.helpers.unpack(p.Unmatched);

    blk = matsim.library.Subsystem(args{:});
    ports = blk.getPorts();
    
    if ~any(strcmp(p.UsingDefaults,'Enable')) || isempty(ports.enable)
        blk.enable(enable);
    end
end
