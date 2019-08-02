function [ports] = getBlockPorts(block,type)
%GETBLOCKPORTS Returns block port handles as array

h = get_param(block,'porthandles');

switch type
    case 'all'
        if matsim.utils.getversion() >= 2015
            ports = [h.Inport, h.Enable, h.Trigger, h.Reset, h.Ifaction, h.Outport];
        else
            ports = [h.Inport, h.Enable, h.Trigger, h.Ifaction, h.Outport];
        end
    case 'input'
        if matsim.utils.getversion() >= 2015
            ports = [h.Inport, h.Enable, h.Trigger, h.Reset, h.Ifaction];
        else
            ports = [h.Inport, h.Enable, h.Trigger, h.Ifaction];
        end
    case 'output'
        ports = [h.Outport];
    case 'special'
        if matsim.utils.getversion() >= 2015
            ports = [h.Enable, h.Trigger, h.Reset, h.Ifaction];
        else
            ports = [h.Enable, h.Trigger, h.Ifaction];
        end
    otherwise
        error('Invalid port type.')
end

end

