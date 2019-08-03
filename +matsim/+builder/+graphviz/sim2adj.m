function [adjMatrix, blocksToLayout] = sim2adj(sys,blocksToLayout)
%SIM2ADJ simulink system to adjacency matrix

    if isempty(blocksToLayout)
        all_blocks = matsim.helpers.findBlock(sys,'SearchDepth',1);
        all_blocks = all_blocks(all_blocks ~= sys); % Remove self
        blocksToLayout = all_blocks;        
    end
    
    adjMatrix = cell(length(blocksToLayout),length(blocksToLayout));
    
    for i=1:length(blocksToLayout)
        set(blocksToLayout(i),'Tag',mat2str(i));
    end
    
    for i=1:length(blocksToLayout)
        neighbours = matsim.builder.graphviz.getNeighbours(sys,blocksToLayout(i));
        for j=1:size(neighbours,1)
            if neighbours(j,1) == -1, continue, end;
            if ~ismember(neighbours(j,1),blocksToLayout), continue, end;
            col = str2double(get(neighbours(j,1),'Tag'));            
            adjMatrix{i,col} = neighbours(j,:); 
        end
    end
end
