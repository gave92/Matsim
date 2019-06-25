function [] = simlayout(varargin)
%SIMLAYOUT Layouts a simulink model

    p = inputParser;
    p.CaseSensitive = false;
    p.KeepUnmatched = true;
    addRequired(p,'sys',@ishandle);
    parse(p,varargin{:})

    sys = p.Results.sys;

    % Build adjacency matrix
    [adjMatrix, blocks] = matsim.builder.graphviz.sim2adj(sys);
    if isempty(blocks), return, end
    
    % Call graphviz
    layout = matsim.builder.graphviz.genLayout(adjMatrix,blocks);    
    locs = layout.centers;

    % Recursively set blocks position
    for i=1:length(blocks)
        % Get more information for position calculation
        blockSizeRef = get(blocks(i),'Position');

        width = blockSizeRef(3) - blockSizeRef(1);
        height = blockSizeRef(4) - blockSizeRef(2);
        p_X = locs(i,1);
        p_Y = locs(i,2);
        location = [p_X-ceil(width/2) p_Y-ceil(height/2) p_X+floor(width/2) p_Y+floor(height/2)];
        set(blocks(i),'position',location)
        
        % Layout subsystem, if not a chart
        % 2011: ~strcmp(get(blocks(i),'MaskType'),'Stateflow')
        if strcmp(get(blocks(i),'blocktype'),'SubSystem') && ...
                strcmp(get(blocks(i),'SFBlockType'),'NONE')
            matsim.builder.graphviz.simlayout(blocks(i))
            set(blocks(i),'ZoomFactor','FitSystem')
        end
    end
    
    % Improve layout
    passes = 1;
    layout = matsim.utils.handlevar(layout);
    tryAlignBlocks(layout);
    while layout.Value.dirty
        if passes>3
            warning('MATSIM:Layout','Loop detected: stopping layout.');
            break
        end
        tryAlignBlocks(layout);
        passes = passes+1;        
    end
    tryAlignRoots(layout);
    
    % Create lines
    for i=1:length(blocks)        
        h = get(blocks(i),'PortHandles');
        if matsim.utils.getversion() >= 2015
            ports = [h.Inport, h.Enable, h.Trigger, h.Reset, h.Ifaction];
        else
            ports = [h.Inport, h.Enable, h.Trigger, h.Ifaction];
        end
        parents = matsim.builder.graphviz.getNeighbours(sys,blocks(i));

        port_num = get(ports,'portnumber');
        if iscell(port_num)
            port_num = cell2mat(port_num);
        end
        line = get(ports,'line');
        if ~iscell(line), line={line}; end
        delete_line(cell2mat(line(cell2mat(line)~=-1)));

        for p = 1:size(parents,1)
            onum = parents(p,2);
            inum = parents(p,3);

            if parents(p,1) ~= -1 && onum ~= -1 % onum = -1 is implicit connection (goto->from)
                h1 = get(parents(p,1),'PortHandles');
                add_line(get(blocks(i),'parent'),h1.Outport(onum),ports(port_num==inum),'autorouting','on');
            end
        end
    end
end

function [] = tryAlignBlocks(layout)
    layout.Value.dirty = 0;    
    % Convert adjMatrix to boolean
    layout.Value.adjBool = cell2mat(arrayfun(@(i) ~cellfun(@isempty,layout.Value.adjMatrix(:,i)),1:size(layout.Value.adjMatrix,2),'uni',0));    
    % Get blocks rank
    getRank(layout);
    % Get blocks without outputs (adj i-column all 0)
    roots = layout.Value.blocks(arrayfun(@(i) all(layout.Value.adjBool(:,i)==0),1:size(layout.Value.adjBool,2)));
    % Also use minimum rank (right-most) blocks
    roots = union(roots,layout.Value.blocks(layout.Value.ranks==min(layout.Value.ranks)));
    % Layout blocks
    layout.Value.unvisited = layout.Value.blocks;    
    for i = 1:length(roots)
        tryAlignBlocks2(roots(i),layout);
    end    
end

function [] = tryAlignRoots(layout)
    % Get blocks without outputs (adj i-column all 0)
    roots = layout.Value.blocks(arrayfun(@(i) all(layout.Value.adjBool(:,i)==0),1:size(layout.Value.adjBool,2)));
    % Also use minimum rank (right-most) blocks
    roots = union(roots,layout.Value.blocks(layout.Value.ranks==min(layout.Value.ranks)));
    % Layout roots
    for i = 1:length(roots)
        tryAlignRoots2(roots(i),layout);
    end
end

function [] = tryAlignRoots2(block,layout)
    blk_idx = str2double(get(block,'tag'));
    parents = layout.Value.blocks(layout.Value.adjBool(blk_idx,:));
    if ~isempty(parents)
        parent_idx = str2double(get(parents(1),'tag'));
        adj = layout.Value.adjMatrix{blk_idx,parent_idx};
        hparent = get(parents(1),'porthandles');
        oports = [hparent.Outport];
        hblk = get(block,'porthandles');
        if matsim.utils.getversion() >= 2015
            ports = [hblk.Inport, hblk.Enable, hblk.Trigger, hblk.Reset, hblk.Ifaction];
        else
            ports = [hblk.Inport, hblk.Enable, hblk.Trigger, hblk.Ifaction];
        end
        if adj(2) ~= -1
            blockSizeRef = get(block,'Position');
            % width = blockSizeRef(3) - blockSizeRef(1);
            height = blockSizeRef(4) - blockSizeRef(2);
            if strcmpi(get(ports(adj(3)),'porttype'),'inport')
                port_pos = get(oports(adj(2)),'position');
            else
                if matsim.utils.getversion() >= 2015
                    order = find([hblk.Enable, hblk.Trigger, hblk.Reset, hblk.Ifaction]==ports(adj(3)));
                else
                    order = find([hblk.Enable, hblk.Trigger, hblk.Ifaction]==ports(adj(3)));
                end
                port_pos = get(oports(adj(3)),'position');
                port_pos(2) = port_pos(2)+42*order;
            end            
            iport_pos = get(ports(adj(3)),'position');
            yTL = port_pos(2)-(iport_pos(2)-blockSizeRef(2));
            location = [blockSizeRef(1) yTL blockSizeRef(3) yTL+height];
            set(block,'position',location)
            intermediateRank = setdiff(layout.Value.blocks(layout.Value.ranks>=layout.Value.ranks(blk_idx) & layout.Value.ranks<layout.Value.ranks(parent_idx)),block);
            if ~matsim.builder.common.detectOverlaps(block,intermediateRank,'OverlapType','Vertical') && ...
                    ~matsim.builder.common.detectOverlaps(block,setdiff(layout.Value.blocks,block),'OverlapType','All')
                if port_pos(2) ~= layout.Value.centers(blk_idx,2)
                    layout.Value.centers(blk_idx,2) = port_pos(2);
                    layout.Value.dirty = 1; % Something changed
                end
            else
                location = [blockSizeRef(1) layout.Value.centers(blk_idx,2)-ceil(height/2) blockSizeRef(3) layout.Value.centers(blk_idx,2)+floor(height/2)];
                set(block,'position',location)
            end
        end
    end
end

function [] = tryAlignBlocks2(block,layout)
    % DFS
    if isempty(find(layout.Value.unvisited==block,1)), return; end
    layout.Value.unvisited = setdiff(layout.Value.unvisited,block);
    blk_idx = str2double(get(block,'tag'));
    children = layout.Value.blocks(layout.Value.adjBool(:,blk_idx));
    if ~isempty(children)
        children_idx = str2double(get(children,'tag'));
        if iscell(children_idx), children_idx = cell2mat(children_idx); end
        children = children(layout.Value.ranks(children_idx)<layout.Value.ranks(blk_idx));
    end
    if ~isempty(children)
        children_pos = get(children,'position');
        if iscell(children_pos), children_pos = cell2mat(children_pos); end
        [~,cidx] = max(children_pos(:,2));
        child_idx = str2double(get(children(cidx),'tag'));
        adj = layout.Value.adjMatrix{child_idx,blk_idx};
        hchild = get(children(cidx),'porthandles');
        if matsim.utils.getversion() >= 2015
            ports = [hchild.Inport, hchild.Enable, hchild.Trigger, hchild.Reset, hchild.Ifaction];
        else
            ports = [hchild.Inport, hchild.Enable, hchild.Trigger, hchild.Ifaction];
        end
        hblk = get(block,'porthandles');
        oports = [hblk.Outport];
        if adj(2) ~= -1
            blockSizeRef = get(block,'Position');
            % width = blockSizeRef(3) - blockSizeRef(1);
            height = blockSizeRef(4) - blockSizeRef(2);
            if strcmpi(get(ports(adj(3)),'porttype'),'inport')
                port_pos = get(ports(adj(3)),'position');
            else
                if matsim.utils.getversion() >= 2015
                    order = find([hchild.Enable, hchild.Trigger, hchild.Reset, hchild.Ifaction]==ports(adj(3)));
                else
                    order = find([hchild.Enable, hchild.Trigger, hchild.Ifaction]==ports(adj(3)));
                end
                port_pos = get(ports(adj(3)),'position');
                port_pos(2) = port_pos(2)-42*order;
            end            
            oport_pos = get(oports(adj(2)),'position');
            yTL = port_pos(2)-(oport_pos(2)-blockSizeRef(2));
            location = [blockSizeRef(1) yTL blockSizeRef(3) yTL+height];
            set(block,'position',location)
            intermediateRank = setdiff(layout.Value.blocks(layout.Value.ranks<=layout.Value.ranks(blk_idx) & layout.Value.ranks>layout.Value.ranks(child_idx)),block);
            if ~matsim.builder.common.detectOverlaps(block,intermediateRank,'OverlapType','Vertical') && ...
                    ~matsim.builder.common.detectOverlaps(block,setdiff(layout.Value.blocks,block),'OverlapType','All')
                if port_pos(2) ~= layout.Value.centers(blk_idx,2)
                    layout.Value.centers(blk_idx,2) = port_pos(2);
                    layout.Value.dirty = 1; % Something changed
                end
            else
                location = [blockSizeRef(1) layout.Value.centers(blk_idx,2)-ceil(height/2) blockSizeRef(3) layout.Value.centers(blk_idx,2)+floor(height/2)];
                set(block,'position',location)
            end
        end
    end
    parents = layout.Value.blocks(layout.Value.adjBool(blk_idx,:));
    for i = 1:length(parents)
        tryAlignBlocks2(parents(i),layout);
    end
end

function [] = getRank(layout)
    % Find block rank based on x-position
    layout.Value.ranks = zeros(1,length(layout.Value.blocks));
    centers = zeros(length(layout.Value.blocks),2);
    for i = 1:length(layout.Value.blocks)
        blockSizeRef = get(layout.Value.blocks(i),'Position');
        width = blockSizeRef(3) - blockSizeRef(1);
        height = blockSizeRef(4) - blockSizeRef(2);
        centers(i,:) = [blockSizeRef(1)+ceil(width/2), blockSizeRef(2)+ceil(height/2)];
    end
    xcenters = [];
    for i = 1:size(centers,1)
        % HACK: Centers are not perfectly aligned
        if isempty(find(abs(centers(i,1)-xcenters)<5,1))
            xcenters = [xcenters, centers(i,1)];
        end
    end
    xcenters = sort(xcenters,2,'descend');
    for i = 1:length(layout.Value.blocks)
        blockSizeRef = get(layout.Value.blocks(i),'Position');
        width = blockSizeRef(3) - blockSizeRef(1);
        xcenter = blockSizeRef(1)+ceil(width/2);
        [~,layout.Value.ranks(i)] = min(abs(xcenters-xcenter));
    end
end

