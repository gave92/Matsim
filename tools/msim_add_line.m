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
        inports = free_inports(matsim.utils.getBlockPorts(dests,'input'));        
        outports = [outports{:}];
        if isempty(inports) || isempty(outports), return, end
        locs = get(outports,'position');
        if iscell(locs), locs = cell2mat(locs); end
        [~,sortIdx] = sort(locs(:,2));
        hline = arrayfun(@(idx) add_line(get_param(srcs(1),'parent'),outports(sortIdx(idx)),inports(idx),'AutoRouting','on'),1:min(numel(outports),numel(inports)));
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
        inports = free_inports([inports{:}]);
        if isempty(inports) || isempty(outports), return, end
        locs = get(inports,'position');
        if iscell(locs), locs = cell2mat(locs); end
        [~,sortIdx] = sort(locs(:,2));
        if numel(outports) ~= 1
            hline = arrayfun(@(idx) add_line(get_param(srcs(1),'parent'),outports(idx),inports(sortIdx(idx)),'AutoRouting','on'),1:min(numel(inports),numel(outports)));
        else
            hline = arrayfun(@(idx) add_line(get_param(srcs(1),'parent'),outports(1),inports(sortIdx(idx)),'AutoRouting','on'),1:numel(inports));
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
        outports = [outports{:}];
        inports = free_inports([inports{:}]);
        if isempty(inports) || isempty(outports), return, end
        locs = get(inports,'position');
        if iscell(locs), locs = cell2mat(locs); end
        [~,sortInportIdx] = sort(locs(:,2));
        locs = get(outports,'position');
        if iscell(locs), locs = cell2mat(locs); end
        [~,sortOutportIdx] = sort(locs(:,2));
        hline = arrayfun(@(idx) add_line(get_param(srcs(1),'parent'),outports(sortOutportIdx(idx)),inports(sortInportIdx(idx)),'AutoRouting','on'),1:min(numel(inports),numel(outports)));
    else
        % One to one
        if iscell(srcs)
            srcs = cellfun(@(b) get_param(b,'handle'),srcs,'uni',1);
        end
        if iscell(dests)
            dests = cellfun(@(b) get_param(b,'handle'),dests,'uni',1);
        end
        outports = matsim.utils.getBlockPorts(srcs,'output');
        inports = free_inports(matsim.utils.getBlockPorts(dests,'input'));
        if isempty(inports) || isempty(outports), return, end
        hline = arrayfun(@(idx) add_line(get_param(srcs(1),'parent'),outports(idx),inports(idx),'AutoRouting','on'),1:min(numel(inports),numel(outports)));
    end
end

function free = free_inports(inports)
    if numel(inports)>1
        free = inports(cell2mat(get(inports,'line'))==-1);
    else
        free = inports(get(inports,'line')==-1);
    end
end
