function hline = msim_add_line(srcs,dests)
%MSIM_ADD_LINE Create line(s) connecting simulink blocks.
    
    if isempty(srcs) || isempty(dests)
        error('Empty source or destination.');
    end
    
    if ~ischar(srcs) && ~isscalar(srcs) && isscalar(dests)
        % Many to one
        if iscell(srcs)
            srcs = cellfun(@(b) get_param(b,'handle'),srcs,'uni',1);
        end
        if iscell(dests)
            dests = cellfun(@(b) get_param(b,'handle'),dests,'uni',1);
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
        locs = get(outports,'position');
        if iscell(locs), locs = cell2mat(locs); end
        [~,sortIdx] = sort(locs(:,2));
        hline = arrayfun(@(idx) add_line(get_param(srcs(idx),'parent'),outports(sortIdx(idx)),inports(idx),'AutoRouting','on'),1:numel(srcs));
    elseif isscalar(srcs) && ~ischar(dests) && ~isscalar(dests)
        % One to many
        if iscell(srcs)
            srcs = cellfun(@(b) get_param(b,'handle'),srcs,'uni',1);
        end
        if iscell(dests)
            dests = cellfun(@(b) get_param(b,'handle'),dests,'uni',1);
        end
        inports = arrayfun(@(b) matsim.utils.getBlockPorts(b,'input'),dests,'uni',0);
        outports = matsim.utils.getBlockPorts(srcs,'output');
        if any(cellfun(@length,inports)>1)
            error('Unsupported number of ports');
        end
        inports = [inports{:}];
        locs = get(inports,'position');
        if iscell(locs), locs = cell2mat(locs); end
        [~,sortIdx] = sort(locs(:,2));
        if numel(outports) ~= 1 && numel(outports) < numel(inports)
            error('Source block does not have enough outputs');
        elseif numel(outports) ~= 1
            hline = arrayfun(@(idx) add_line(get_param(srcs,'parent'),outports(idx),inports(sortIdx(idx)),'AutoRouting','on'),1:numel(dests));
        else
            hline = arrayfun(@(idx) add_line(get_param(srcs,'parent'),outports(1),inports(sortIdx(idx)),'AutoRouting','on'),1:numel(dests));
        end        
    elseif ~ischar(srcs) && ~isscalar(srcs) && ~ischar(dests) && ~isscalar(dests)
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
        locs = get(inports,'position');
        if iscell(locs), locs = cell2mat(locs); end
        [~,sortInportIdx] = sort(locs(:,2));
        locs = get(outports,'position');
        if iscell(locs), locs = cell2mat(locs); end
        [~,sortOutportIdx] = sort(locs(:,2));
        hline = arrayfun(@(idx) add_line(get_param(srcs(idx),'parent'),outports(sortOutportIdx(idx)),inports(sortInportIdx(idx)),'AutoRouting','on'),1:numel(srcs));
    else
        % One to one
        if iscell(srcs)
            srcs = cellfun(@(b) get_param(b,'handle'),srcs,'uni',1);
        end
        if iscell(dests)
            dests = cellfun(@(b) get_param(b,'handle'),dests,'uni',1);
        end
        outports = matsim.utils.getBlockPorts(srcs,'output');
        inports = matsim.utils.getBlockPorts(dests,'input');
        if numel(outports) < numel(inports)
            error('Source block does not have enough outputs');
        end
        hline = arrayfun(@(idx) add_line(get_param(srcs,'parent'),outports(idx),inports(idx),'AutoRouting','on'),1:numel(inports));
    end
end
