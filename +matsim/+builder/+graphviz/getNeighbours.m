function neighbours = getNeighbours(sys,root)
%GETNEIGHBOURS Find ancestors of block

    neighbours = [];
    
    data = get(root,'UserData');
    if ~isempty(data) && isfield(data,'block') && ~isempty(data.block)
        inputs = data.block.inputs;
        if ~isempty(inputs)
            % Ordine porte Simulink: [N Inports, 0/1 Enables, 0/1 Triggers]
            in = inputs.inport(cellfun(@(x) isa(x,'matsim.library.block_input'),inputs.inport));
            en = inputs.enable(cellfun(@(x) isa(x,'matsim.library.block_input'),inputs.enable));
            tr = inputs.trigger(cellfun(@(x) isa(x,'matsim.library.block_input'),inputs.trigger));
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
    
    % Create edges between gotos and froms so the final graph will place
    % them closer to each other
    if strcmp(get(root,'blocktype'),'From')
        GotoTag = get(root, 'Gototag');
        Gotos = matsim.helpers.findBlock(sys,'SearchDepth',1,'BlockType','Goto','Gototag',GotoTag);
        for i = 1:length(Gotos)
            in = [get(Gotos(i),'handle'), -1, 1]; % -1 is implicit connection
            neighbours = [neighbours; in];
        end
    end
    
    if ~isempty(neighbours)
        % [~,u] = unique(neighbours(:,1),'stable');
        % neighbours = neighbours(u,:);
    end
end

