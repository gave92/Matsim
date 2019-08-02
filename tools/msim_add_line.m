function hline = msim_add_line(srcs,dests)
%MSIM_ADD_LINE Create line(s) connecting simulink blocks.
    
    if ~ischar(srcs) && isvector(srcs) && isscalar(dests)
        % Many to one
        if iscell(srcs)
            srcs = cellfun(@(b) get_param(b,'handle'),srcs,'uni',1);
        end
        outports = arrayfun(@(b) matsim.utils.getBlockPorts(b,'output'),srcs,'uni',0);
        inports = matsim.utils.getBlockPorts(dests,'input');
        if any(cellfun(@length,outports)>1)
            error('Unsupported number of ports');
        end
        outports = [outports{:}];
        if numel(outports) > numel(inports)
            error('Destination block does not have enough inputs');
        end
        hline = arrayfun(@(idx) add_line(get_param(srcs(idx),'parent'),outports(idx),inports(idx),'AutoRouting','on'),1:numel(srcs));
    elseif isscalar(srcs) && ~ischar(dests) && isvector(dests)
        % One to many
        if iscell(dests)
            dests = cellfun(@(b) get_param(b,'handle'),dests,'uni',1);
        end
        inports = arrayfun(@(b) matsim.utils.getBlockPorts(b,'input'),dests,'uni',0);
        outports = matsim.utils.getBlockPorts(srcs,'output');
        if numel(outports) ~= 1 || any(cellfun(@length,inports)>1)
            error('Unsupported number of ports');
        end
        inports = [inports{:}];
        hline = arrayfun(@(idx) add_line(get_param(srcs,'parent'),outports,inports(idx),'AutoRouting','on'),1:numel(dests));
    elseif ~ischar(srcs) && isvector(srcs) && ~ischar(dests) && isvector(dests)
        % Many to many
        if iscell(srcs)
            srcs = cellfun(@(b) get_param(b,'handle'),srcs,'uni',1);
        end
        if iscell(dests)
            dests = cellfun(@(b) get_param(b,'handle'),dests,'uni',1);
        end
        inports = arrayfun(@(b) matsim.utils.getBlockPorts(b,'input'),dests,'uni',0);
        outports = arrayfun(@(b) matsim.utils.getBlockPorts(b,'output'),srcs,'uni',0);
        if any(cellfun(@length,outports)>1) || any(cellfun(@length,inports)>1)
            error('Unsupported number of ports');
        end
        outports = [outports{:}];
        inports = [inports{:}];
        if numel(outports) > numel(inports)
            error('Incompatible number of blocks');
        end        
        hline = arrayfun(@(idx) add_line(get_param(srcs(idx),'parent'),outports(idx),inports(idx),'AutoRouting','on'),1:numel(srcs));
    else
        % One to one
        outports = matsim.utils.getBlockPorts(srcs,'output');
        inports = matsim.utils.getBlockPorts(dests,'input');
        if numel(outports) ~= 1 || numel(inports) ~= 1
            error('Unsupported number of ports');
        end
        hline = add_line(get_param(srcs,'parent'),outports,inports,'AutoRouting','on');
    end
end

