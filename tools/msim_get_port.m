function [port] = msim_get_port(block,index,type)
%MSIM_GET_PORT Gets specified port of simulink block.

    if nargin < 2
        index = 1;
    end
    if nargin < 3
        type = 'all';
    end

    ports = matsim.utils.getBlockPorts(block,type);
    
    if index <= numel(ports)
        port = ports(index);
    else
        error('Invalid port index.')
    end
end

