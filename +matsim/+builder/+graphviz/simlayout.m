function [] = simlayout(varargin)
%SIMLAYOUT Layouts a simulink model

    p = inputParser;
    p.CaseSensitive = false;
    % p.PartialMatching = false;
    p.KeepUnmatched = true;
    addRequired(p,'sys',@ishandle);
    addParamValue(p,'ConnectOnly',false,@islogical);
    parse(p,varargin{:})

    sys = p.Results.sys;
    connect_only = p.Results.ConnectOnly;

    [adjMatrix, blocks] = matsim.builder.graphviz.sim2adj(sys);
    if isempty(blocks), return, end
    
    if ~connect_only
        layout = matsim.builder.graphviz.genLayout(adjMatrix,blocks);
        locs = layout.centers;
    end
    
    for i=1:length(blocks)
        if ~connect_only
            % Get more information for position calculation
            blockSizeRef = get(blocks(i),'Position');

            width = blockSizeRef(3) - blockSizeRef(1);
            height = blockSizeRef(4) - blockSizeRef(2);
            p_X = locs(i,1);
            p_Y = locs(i,2);
            location = [p_X-ceil(width/2) p_Y-ceil(height/2) p_X+floor(width/2) p_Y+floor(height/2)];
            set(blocks(i),'position',location)
        end
        
        % Layout subsystem, if not a chart
        % 2011: ~strcmp(get(blocks(i),'MaskType'),'Stateflow')
        if strcmp(get(blocks(i),'blocktype'),'SubSystem') && ...
                strcmp(get(blocks(i),'SFBlockType'),'NONE')
            matsim.builder.graphviz.simlayout(blocks(i),'ConnectOnly',connect_only)
            set(blocks(i),'ZoomFactor','FitSystem')
        end
    end
    
    for i=1:length(blocks)
        % Create lines
        h = get(blocks(i),'PortHandles');
        ports = [h.Inport, h.Enable, h.Trigger, h.Reset, h.Ifaction];
        parents = matsim.builder.graphviz.getNeighbours(sys,blocks(i));
        
        for p = 1:size(parents,1)
            onum = parents(p,2);
            inum = parents(p,3);

            port_num = get(ports,'portnumber');
            if iscell(port_num)
                port_num = cell2mat(port_num);
            end
            line = get(ports(port_num==inum),'line');
            if line ~= -1
                % Line exists
                delete_line(line)
            end

            if parents(p,1) ~= -1 && onum ~= -1 % onum = -1 is implicit connection (goto->from)
                h1 = get(parents(p,1),'PortHandles');
                add_line(get(blocks(i),'parent'),h1.Outport(onum),ports(port_num==inum),'autorouting','on');
            end
        end
    end
end

