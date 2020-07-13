function [] = msim_createsubsystem(blocks)
%MSIM_CREATESUBSYSTEM Create subsystem from blocks.
    
    bh = get_param(blocks,'handle');
    if iscell(bh), bh = cell2mat(bh); end    
    pre_handles = find_system(get(bh(1),'parent'),'findall','on','searchdepth',1,'type','block','blocktype','SubSystem');
    Simulink.BlockDiagram.createSubSystem(bh);
    post_handles = find_system(get(bh(1),'parent'),'findall','on','searchdepth',1,'type','block','blocktype','SubSystem');
    new_subsys = setdiff(post_handles,pre_handles);
    if numel(new_subsys)~=1
        error('Something strange happened.')
    end
    
    inports = find_system(new_subsys,'findall','on','searchdepth',1,'type','block','blocktype','Inport');
    outports = find_system(new_subsys,'findall','on','searchdepth',1,'type','block','blocktype','Outport');
    
    for in = 1:numel(inports)
        ph = get(inports(in),'portconnectivity');
        if ~strcmp(get(ph.DstBlock,'blocktype'),'SubSystem'), continue, end
        inport_old = find_system(ph.DstBlock,'findall','on','searchdepth',1,'type','block','blocktype','Inport','Port',num2str(ph.DstPort+1));
        set(inports(in),'name',get(inport_old,'name'))
    end
    for out = 1:numel(outports)
        ph = get(outports(out),'portconnectivity');
        if ~strcmp(get(ph.SrcBlock,'blocktype'),'SubSystem'), continue, end
        outport_old = find_system(ph.SrcBlock,'findall','on','searchdepth',1,'type','block','blocktype','Outport','Port',num2str(ph.SrcPort+1));
        set(outports(out),'name',get(outport_old,'name'))
    end
end
