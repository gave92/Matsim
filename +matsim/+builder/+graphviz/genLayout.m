function obj = genLayout(adjMatrix,blocks)
% Use the graphVIZ package to determine the optimal layout for a graph.

obj = struct;
obj.blocks = blocks;
obj.adjMatrix   = adjMatrix;
obj.layoutFile  = 'layout.dot';
obj.adjFile     = 'adjmat.dot';

bounds = [0, 0, 1, 1];
obj.xmin        = bounds(1);
obj.ymin        = bounds(2);
obj.xmax        = bounds(3);
obj.ymax        = bounds(4);
obj.maxNodeSize = 1;

blockSizeRef = getDimensions(blocks);
if ~isempty(blockSizeRef) && ~iscell(blockSizeRef)
    blockSizeRef = {blockSizeRef};
end
blockSizeRef = vertcat(blockSizeRef{:});
obj.width = blockSizeRef(:,3) - blockSizeRef(:,1);
obj.height = blockSizeRef(:,4) - blockSizeRef(:,2);
    
obj = calcLayout(obj);

end

function blockSizeRef = getDimensions(blocks)
    blockSizeRef = cell(length(blocks),1);
    for i=1:length(blocks)
        ports = get(blocks(i),'porthandles');
        rot = get(ports.Inport,'Rotation');
        if ~iscell(rot), rot = {rot}; end
        inputnum = length(find(mod([rot{:}],2*pi) == 0));
        rot = get(ports.Outport,'Rotation');
        if ~iscell(rot), rot = {rot}; end
        outputnum = length(find(mod([rot{:}],2*pi) == 0));
        pos = get(blocks(i),'position');
        if max(inputnum,outputnum)>1
            pos(4) = pos(2)+42*max([1,inputnum,outputnum]);
        end
        set(blocks(i),'position',pos);
        blockSizeRef{i} = pos;
    end
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
    try
        fprintf(fid,'digraph G {\ncenter=1;\nsize="10,10";\nrankdir="LR";\n');
        fprintf(fid,'graph [ranksep=0.4, nodesep=0.4];\n');
        n = size(obj.adjMatrix,1);
        for i=n:-1:1
            width = obj.width(i)*0.8/30;
            height = obj.height(i)*0.8/30;
            inputnum = length(matsim.utils.getBlockPorts(obj.blocks(i),'input'));
            outputnum = length(matsim.utils.getBlockPorts(obj.blocks(i),'output'));
            dotfile = [num2str(i),' [label="{'];
            if inputnum ~= 0
                dotfile = [dotfile '{'];
                for x = 1:inputnum
                    if x == inputnum
                        dotfile = [dotfile '<i' num2str(x) '>' num2str(x)];
                    else
                        dotfile = [dotfile '<i' num2str(x) '>' num2str(x) '|'];
                    end
                end
                dotfile = [dotfile '}|'];
            end
            dotfile = [dotfile num2str(i)];
            if outputnum ~= 0
                dotfile = [dotfile '|{'];
                for w = 1:outputnum
                    if w == outputnum
                        dotfile = [dotfile '<o' num2str(w) '>' num2str(w)];
                    else
                        dotfile = [dotfile '<o' num2str(w) '>' num2str(w) '|'];
                    end
                end
                dotfile = [dotfile '}'];
            end
            fprintf(fid,'%s}", shape=record, fixedsize=true, width=%f, height=%f];\n',dotfile,width,height);
        end
        edgetxt = ' -> ';
        for i=n:-1:1
            conn = [];
            for j=1:n
                if(~isempty(obj.adjMatrix{i,j}))
                    conn = [conn; [i,j,obj.adjMatrix{i,j}]];
                end
            end
            if isempty(conn), continue; end;
            ports = matsim.utils.getBlockPorts(obj.blocks(i),'input');
            s = matsim.utils.quicksort(conn,@(m,x,y) order_ports(m,x,y,ports));
            conn = conn(s,:);
            conn(:,5) = 1:size(conn,1);
            for j=1:size(conn,1)
                if conn(j,4) == -1 % conn(j,4) = -1 is implicit connection (goto->from)
                    fprintf(fid,'%d%s%d;\n',conn(j,2),edgetxt,i);
                else
                    fprintf(fid,'%d:o%d%s%d:i%d;\n',conn(j,2),conn(j,4),edgetxt,i,conn(j,5));
                end
            end
        end       

        fprintf(fid,'}');
    catch ex
        fclose(fid);
        rethrow(ex)
    end
    fclose(fid);
end

function comp = order_ports(m,x,y,ports)
    ports_order = {'ifaction','reset','trigger','enable','inport'};
    if m(x,4) == -1 && m(y,4) == -1
        comp = 0;
    elseif m(x,4) == -1 && m(y,4) ~= -1
        comp = -1;
    elseif m(x,4) ~= -1 && m(y,4) == -1
        comp = 1;
    else
        pt1 = ports(m(x,5));
        pt2 = ports(m(y,5));
        if strcmpi(get(pt1,'porttype'),get(pt2,'porttype'))
            comp = sign(get(pt1,'portnumber') - get(pt2,'portnumber'));
        else
            comp = sign(find(strcmpi(ports_order,get(pt1,'porttype')),1) - find(strcmpi(ports_order,get(pt2,'porttype')),1));
        end
    end
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

    locations(:,2) = dims(4)-locations(:,2);
    obj.centers = locations;
end

function cleanup(obj)
% delete the temporary files. 
   % !dot -Tpng adjmat.dot -o graph.png
   delete(obj.adjFile);
   delete(obj.layoutFile);
end
       
