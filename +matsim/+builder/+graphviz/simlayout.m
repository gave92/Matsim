function [] = simlayout(varargin)
%SIMLAYOUT Layouts a simulink model

    p = inputParser;
    p.CaseSensitive = false;
    p.KeepUnmatched = true;
    addRequired(p,'sys',@ishandle);
    addParamValue(p,'Recursive',false,@islogical);
    addParamValue(p,'Blocks',[],@(x) all(ishandle(x)) || (iscell(x) && all(cellfun(@(b) ischar(b) || isa(b,'matsim.library.block') || ishandle(b),x))));
    parse(p,varargin{:})

    sys = p.Results.sys;
    recursive = p.Results.Recursive;

    % Only layout specified blocks
    blocksToLayout = p.Results.Blocks;
    if ~isempty(blocksToLayout)
        if iscell(blocksToLayout)
            blocksToLayout = cellfun(@(b) get_param(b,'handle'),blocksToLayout);
        else
            blocksToLayout = get_param(blocksToLayout,'handle');
            if iscell(blocksToLayout), blocksToLayout = cell2mat(blocksToLayout); end
        end
    end

    % Build adjacency matrix
    [adjMatrix, blocks] = matsim.builder.graphviz.sim2adj(sys,blocksToLayout);
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
        if recursive && strcmp(get(blocks(i),'blocktype'),'SubSystem') && ...
                strcmp(get(blocks(i),'SFBlockType'),'NONE')
            matsim.builder.graphviz.simlayout(blocks(i))
            set(blocks(i),'ZoomFactor','FitSystem')
        end
    end
    
    layout = matsim.utils.handlevar(layout);
    
    % Try align blocks
    passes = 1;    
    tryAlignBlocks(layout);
    while layout.Value.dirty
        if passes>5
            warning('MATSIM:Layout','Loop detected: stopping layout.');
            break
        end
        tryAlignBlocks(layout);
        passes = passes+1;        
    end
    
    % Try align roots
    passes = 1;
    tryAlignRoots(layout);
    while layout.Value.dirty
        if passes>5
            warning('MATSIM:Layout','Loop detected: stopping layout.');
            break
        end
        tryAlignRoots(layout);
        passes = passes+1;        
    end    
    
    % Move to empty place
    if ~isempty(blocksToLayout)
        tryMoveBlocks(layout,sys);
    end
    
    % Create lines
    for i=1:length(blocks)
        ports = matsim.utils.getBlockPorts(blocks(i),'input');
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
    layout.Value.dirty = 0;
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
        if adj(2) ~= -1
            oports = matsim.utils.getBlockPorts(parents(1),'output');
            ports = matsim.utils.getBlockPorts(block,'input');
            if strcmpi(get(ports(adj(3)),'porttype'),'inport')
                port_pos = get(oports(adj(2)),'position');
            else
                special = matsim.utils.getBlockPorts(block,'special');
                order = find(special==ports(adj(3)));
                port_pos = get(oports(adj(2)),'position');
                port_pos(2) = port_pos(2)+42*order;
            end
            iport_pos = get(ports(adj(3)),'position');
        else
            block_pos = get(block,'Position');
            parent_pos = get(parents(1),'Position');
            port_pos = [parent_pos(1)+parent_pos(3), parent_pos(2)+ceil((parent_pos(4)-parent_pos(2))/2)];
            iport_pos = [block_pos(1), block_pos(2)+ceil((block_pos(4)-block_pos(2))/2)];
        end
        blockSizeRef = get(block,'Position');
        % width = blockSizeRef(3) - blockSizeRef(1);
        height = blockSizeRef(4) - blockSizeRef(2);
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
        if adj(2) ~= -1            
            ports = matsim.utils.getBlockPorts(children(cidx),'input');
            oports = matsim.utils.getBlockPorts(block,'output');
            if strcmpi(get(ports(adj(3)),'porttype'),'inport')
                port_pos = get(ports(adj(3)),'position');
            else
                special = matsim.utils.getBlockPorts(children(cidx),'special');
                order = find(special==ports(adj(3)));
                port_pos = get(ports(adj(3)),'position');
                port_pos(2) = port_pos(2)-42*order;
            end
            oport_pos = get(oports(adj(2)),'position');
        else
            block_pos = get(block,'Position');
            child_pos = get(children(cidx),'Position');
            port_pos = [child_pos(1), child_pos(2)+ceil((child_pos(4)-child_pos(2))/2)];
            oport_pos = [block_pos(1)+block_pos(3), block_pos(2)+ceil((block_pos(4)-block_pos(2))/2)];
        end
        blockSizeRef = get(block,'Position');
        % width = blockSizeRef(3) - blockSizeRef(1);
        height = blockSizeRef(4) - blockSizeRef(2);
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

function [] = tryMoveBlocks(layout,sys)
    other_blocks = matsim.helpers.findBlock(sys,'SearchDepth',1);
    other_blocks = setdiff(other_blocks,[sys;layout.Value.blocks(:)]); % Remove self    
    if isempty(other_blocks), return; end
    oBlocksSize = get(other_blocks,'Position');
    if iscell(oBlocksSize), oBlocksSize = cell2mat(oBlocksSize); end
    lBlocksSize = get(layout.Value.blocks,'Position');
    if iscell(lBlocksSize), lBlocksSize = cell2mat(lBlocksSize); end
    
    lBlocksSize(:,[2,4]) = lBlocksSize(:,[2,4])-min(lBlocksSize(:,2));
    lBlocksSize(:,[2,4]) = lBlocksSize(:,[2,4])+max(oBlocksSize(:,4))+42;
    arrayfun(@(b) set(layout.Value.blocks(b),'position',lBlocksSize(b,:)),1:numel(layout.Value.blocks))
end

