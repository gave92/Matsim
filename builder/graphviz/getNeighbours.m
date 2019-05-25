function neighbours = getNeighbours(root)
%GETNEIGHBOURS Find ancestors of block

    neighbours = [];
    
    data = get(root,'UserData');
    if ~isempty(data) && isfield(data,'block') && ~isempty(data.block)
        inputs = data.block.inputs;
        if ~isempty(inputs)
            if ~iscell(inputs), inputs = {inputs}; end
            
            % Ordine porte Simulink: [N Inports, 0/1 Enables, 0/1 Triggers]
            in = inputs(cellfun(@(x) isa(x,'block_input') && strcmp(x.type,'input'),inputs));
            en = inputs(cellfun(@(x) isa(x,'block_input') && strcmp(x.type,'enable'),inputs));
            tr = inputs(cellfun(@(x) isa(x,'block_input') && strcmp(x.type,'trigger'),inputs));
            inputs = [in,en,tr];
            
            for i=1:length(inputs)
                if ~isempty(inputs{i}.value)
                    in = [inputs{i}.value.get('handle'), inputs{i}.srcport, i];
                    neighbours = [neighbours; in];
                else
                    in = [-1, inputs{i}.srcport, i];
                    neighbours = [neighbours; in];
                end
            end
        end
    else
        ports = get(root,'porthandles');
        ports = [ports.Inport, ports.Enable, ports.Trigger];
        for i=1:length(ports)
            line = get(ports(i),'line');
            if (line == -1 || get(line,'SrcBlockHandle') == -1), continue; end;
            neighbours = [neighbours; [get(line,'SrcBlockHandle'), get(get(line,'SrcPortHandle'),'PortNumber'), get(ports(i),'PortNumber')]];
        end
    end    
    
    if ~isempty(neighbours)
        % [~,u] = unique(neighbours(:,1),'stable');
        % neighbours = neighbours(u,:);
    end
end

