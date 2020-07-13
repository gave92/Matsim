function [] = msim_align(hBlocks)
%MSIM_ALIGN Align blocks to inport or outport.
% Syntax:
%   msim_align(BLOCKS);
%     BLOCKS is a vector containing the blocks to align
%     BLOCKS can be:
%       - a cell array of strings
%       - a double array of block handles

    if iscellstr(hBlocks)
        hBlocks = cellfun(@(b) get_param(b,'handle'),hBlocks,'uni',1);
    end

    for bb = 1:numel(hBlocks)
        ports = get(hBlocks(bb),'porthandles');
        if numel(ports.Outport)==1
            line = get(ports.Outport,'Line');
            if line==-1, continue, end
            dst = get(line,'DstPortHandle');
            if numel(dst)~=1 || dst==-1, continue, end
            blk_pos = get(hBlocks(bb),'Position');
            port_pos = get(dst,'Position');
            new_y = port_pos(2)-(blk_pos(4)-blk_pos(2))/2;
            new_h = port_pos(2)+(blk_pos(4)-blk_pos(2))/2;
            set(hBlocks(bb),'Position',[blk_pos(1) new_y blk_pos(3) new_h])
        elseif numel(ports.Inport)==1
            line = get(ports.Inport,'Line');
            if line==-1, continue, end
            src = get(line,'SrcPortHandle');
            if numel(src)~=1 || src==-1, continue, end
            blk_pos = get(hBlocks(bb),'Position');
            port_pos = get(src,'Position');
            new_y = port_pos(2)-(blk_pos(4)-blk_pos(2))/2;
            new_h = port_pos(2)+(blk_pos(4)-blk_pos(2))/2;
            set(hBlocks(bb),'Position',[blk_pos(1) new_y blk_pos(3) new_h])
        else
            continue
        end
    end
end
