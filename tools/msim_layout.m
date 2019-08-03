function [] = msim_layout(blocks)
%MSIM_LAYOUT Layout specified blocks.

    if isempty(blocks)
        parent = get_param(gcs,'handle');
        matsim.builder.graphviz.simlayout(parent);
    else
        parent = get_param(get_param(blocks(1),'parent'),'handle');
        if iscell(parent), parent = cell2mat(parent); end
        matsim.builder.graphviz.simlayout(parent,'Blocks',blocks);
    end

end
