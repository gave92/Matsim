function [adjMatrix, blocks] = sim2adj(sys)
%SIM2ADJ simulink system to adjacency matrix

    blocks = helpers.findBlock(sys,'SearchDepth',1);
    blocks = blocks(blocks ~= sys); % Remove self
    adjMatrix = zeros(length(blocks),length(blocks));
    
    for i=1:length(blocks)
        set(blocks(i),'Tag',mat2str(i));
    end
    
    for i=1:length(blocks)  
        neighbours = getNeighbours(blocks(i));
        for j=1:size(neighbours,1)
            if neighbours(j,1) == -1, continue, end;
            col = str2double(get(neighbours(j,1),'Tag'));
            adjMatrix(i,col) = j; 
        end
    end
end
