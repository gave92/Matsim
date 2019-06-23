function [adjMatrix, blocks] = sim2adj(sys)
%SIM2ADJ simulink system to adjacency matrix

    blocks = matsim.helpers.findBlock(sys,'SearchDepth',1);
    blocks = blocks(blocks ~= sys); % Remove self
    adjMatrix = cell(length(blocks),length(blocks));
    
    for i=1:length(blocks)
        set(blocks(i),'Tag',mat2str(i));
    end
    
    for i=1:length(blocks)
        neighbours = matsim.builder.graphviz.getNeighbours(sys,blocks(i));
        for j=1:size(neighbours,1)
            if neighbours(j,1) == -1, continue, end;
            col = str2double(get(neighbours(j,1),'Tag'));
            adjMatrix{i,col} = neighbours(j,:); 
        end
    end
end
