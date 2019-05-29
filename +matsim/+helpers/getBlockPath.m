function [path] = getBlockPath(object)
%GETBLOCKPATH Gets simulink object path
%   path = getBlockPath(object)
%   Object can be of type "simulation", "block", "handle", "string"

    if isa(object,'matsim.library.simulation')
        path = get(object,'Name');
    elseif isa(object,'matsim.library.block')
        path = strjoin({get(object,'Path'),get(object,'Name')},'/');
    elseif isa(object,'matsim.library.block_input')
        path = strjoin({get(object,'Path'),get(object,'Name')},'/');
    elseif ishandle(object)
        if strcmp(get(object,'Type'),'block_diagram')
            path = get(object,'Name');
        else
            path = strjoin({get(object,'Path'),get(object,'Name')},'/');
        end
    elseif ischar(object)
        path = object;
    else
        error('Invalid object')
    end

end

