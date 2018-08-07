function obj = genLayout(adjMatrix,blocks)
% Use the graphVIZ package to determine the optimal layout for a graph.

obj.adjMatrix   = adjMatrix;
obj.layoutFile  = 'layout.dot';
obj.adjFile     = 'adjmat.dot';

bounds = [0, 0, 1, 1];
obj.xmin        = bounds(1);
obj.ymin        = bounds(2);
obj.xmax        = bounds(3);
obj.ymax        = bounds(4);
obj.maxNodeSize = 1;

blockSizeRef = get(blocks,'Position');
if ~isempty(blockSizeRef) && ~iscell(blockSizeRef)
    blockSizeRef = {blockSizeRef};
end
blockSizeRef = vertcat(blockSizeRef{:});
obj.width = blockSizeRef(:,3) - blockSizeRef(:,1);
obj.height = blockSizeRef(:,4) - blockSizeRef(:,2);
    
obj = calcLayout(obj);

end

function obj = calcLayout(obj)
% Have graphViz calculate the layout
  writeDOTfile(obj);
  callGraphViz(obj);
  obj = readLayout(obj);
  cleanup(obj);
end

function writeDOTfile(obj)
% Write the adjacency matrix into a dot file that graphViz can
% understand. 
    fid = fopen('adjmat.dot','w');
    fprintf(fid,'digraph G {\nordering=out;\ncenter=1;\nsize="10,10";\nrankdir="RL";\n');
    fprintf(fid,'graph [ranksep=0.4, nodesep=0.4];\n');
    n = size(obj.adjMatrix,1);
    for i=1:n
        w = obj.width(i)*0.8/30;
        h = obj.height(i)*0.8/30;
        fprintf(fid,'%d [shape=box, fixedsize=true, width=%f, height=%f];\n',i,w,h);
    end
    edgetxt = ' -> ';
    for i=1:n
        conn = [];
        for j=1:n
           if(obj.adjMatrix(i,j))
              conn = [conn; [i,j,obj.adjMatrix(i,j)]];
           end
        end
        if isempty(conn) continue; end;
        [~,s] = sort(conn(:,3));
        conn = conn(s,:);
        for j=1:size(conn,1)
            fprintf(fid,'%d%s%d;\n',i,edgetxt,conn(j,2));
        end
    end       
    
    fprintf(fid,'}');
    fclose(fid);
end

function callGraphViz(obj)
% Call GraphViz to determine an optimal layout. Write this layout in
% layout.dot for later parsing. 
   err = system(['dot -Tdot -Gmaxiter=5000 -Gstart=7 -o ',obj.layoutFile,' ',obj.adjFile]);
   if(err),error('Sorry, unknown GraphViz failure, try another layout'); end
end

function obj = readLayout(obj)
% Parse the layout.dot file for the graphViz node locations and 
% dimensions. 
    fid = fopen(obj.layoutFile,'r');
    text = textscan(fid,'%s','delimiter','\n'); 
    fclose(fid);
    text = text{:};

    % Read Graphviz dimensions
    dim_text = text{strncmp(text, 'graph [bb="', 11)};
    dims = sscanf(dim_text(12:end),'%f,')';

    % Read the position of nodes
    location_tokens = regexp(horzcat(text{:}), ';([0-9]+)\s+\[[^\]]*pos="(-?[0-9\.]+),(-?[0-9\.]+)"', 'tokens');
    location_tokens = vertcat(location_tokens{:});

    % Convert to numeric values
    node_idx = sscanf(strjoin(location_tokens(:,1)), '%d');            
    locations = reshape(sscanf(strjoin(location_tokens(:,2:3)), '%f'),[],2);            
    locations(node_idx,:) = locations; % reorder based on id

    % obj = scaleLocations(obj,locations,dims);
    locations(:,2) = dims(4)-locations(:,2);
    obj.centers = locations;
end

function obj = scaleLocations(obj,locations,graphVizDims)
% Scale the graphViz node locations to the smartgraph dimensions and
% set the node size. 
    dims = graphVizDims; loc = locations;
    loc(:,1) = (loc(:,1)-dims(1)) ./ (dims(3)-dims(1))*(obj.xmax - obj.xmin) + obj.xmin;
    loc(:,2) = (loc(:,2)-dims(2)) ./ (dims(4)-dims(2))*(obj.ymax - obj.ymin) + obj.ymin;
    obj.centers = loc;

    a = min(abs(loc(:,1) - obj.xmin));
    b = min(abs(loc(:,1) - obj.xmax));
    c = min(abs(loc(:,2) - obj.ymin));
    d = min(abs(loc(:,2) - obj.ymax));
    obj.nodeSize = min(2*min([a,b,c,d]),obj.maxNodeSize);

end

function cleanup(obj)
% delete the temporary files. 
   delete(obj.adjFile);
   delete(obj.layoutFile);
end
       
