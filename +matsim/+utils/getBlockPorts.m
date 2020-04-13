function [ports] = getBlockPorts(block,type)
%GETBLOCKPORTS Returns block port handles as array

h = get_param(block,'porthandles');

switch type
    case 'all'
        if isfield(h,'Reset')
            ports = [h.Inport, h.Enable, h.Trigger, h.Reset, h.Ifaction, h.Outport];
        else
            ports = [h.Inport, h.Enable, h.Trigger, h.Ifaction, h.Outport];
        end
    case 'input'
        if isfield(h,'Reset')
            ports = [h.Inport, h.Enable, h.Trigger, h.Reset, h.Ifaction];
        else
            ports = [h.Inport, h.Enable, h.Trigger, h.Ifaction];
        end
    case 'output'
        ports = [h.Outport];
    case 'special'
        if isfield(h,'Reset')
            ports = [h.Enable, h.Trigger, h.Reset, h.Ifaction];
        else
            ports = [h.Enable, h.Trigger, h.Ifaction];
        end
    otherwise
        error('Invalid port type.')
end

end

