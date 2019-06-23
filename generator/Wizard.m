clearvars
close all
clc

blocks = ReadTable();
[~,I] = sort({blocks.name});
blocks = blocks(I);

selected_block = matsim.utils.handlevar([]);
selected_params = matsim.utils.handlevar([]);

fig = figure('Units','norm','Position',[0.2 0.2 0.6 0.6],'Toolbar','none');
set(fig,'Resize','off');

hpanel = uipanel(fig,'Position',[0 0 1 1],'bordertype','none');
hcontent1 = uipanel('Parent',hpanel,'Position',[0 0 0.3 1]);
hcontent2 = uipanel('Parent',hpanel,'Position',[0.3 0 0.7 1]);
bounds1 = getpixelposition(hcontent1);
bounds2 = getpixelposition(hcontent2);

hsearch = uicontrol('Style','edit','Parent',hcontent1,...
        'FontSize',12,'HorizontalAlignment','left', ...
        'String','',...
        'Units','norm','Position', [0 0.95 1 0.05]);
hlb = uicontrol('Style','listbox','Parent',hcontent1,...
        'FontSize',12,'HorizontalAlignment','left', ...
        'String',{blocks.name},...
        'Units','norm','Position', [0 0 1 0.95]);
hname = uicontrol('Style','text','Parent',hcontent2,...
        'FontSize',12,'HorizontalAlignment','left', ...
        'String','',...
        'Units','norm','Position', [0 0.95 0.8 0.05]);
hgen = uicontrol('Style','pushbutton','Parent',hcontent2,...
        'FontSize',12,'HorizontalAlignment','center', ...
        'String','Generate',...
        'Units','norm','Position', [0.8 0.95 0.2 0.05]);
hparams = uitable('Parent',hcontent2,'FontSize',12,...
        'ColumnName', {'Name','Dialog','Type'},...        
        'ColumnWidth', num2cell([bounds2(3)/3,bounds2(3)/3,bounds2(3)/3]-20),...
        'Units','norm','Position', [0 0 1 0.95]);

set(hsearch,'Callback',{@search,blocks,hlb})
set(hlb,'Callback',{@select_list,blocks,hparams,hname,hsearch,selected_block})
set(hparams,'CellSelectionCallback',{@select_table,selected_params})
set(hgen,'Callback',{@generate,selected_block,selected_params})

function [] = search(src,~,blocks,hlb)
    value = get(src,'String');
    if isempty(value)
        set(hlb,'String',{blocks.name})
    else
        blks = blocks(contains(lower({blocks.name}),lower(value)));
        set(hlb,'Value',1)
        set(hlb,'String',{blks.name})
    end
end
function [] = select_list(src,~,blocks,hparams,hname,hsearch,selected_block)
    value = get(src,'Value');
    if value <= 0, return, end
    name = get(hsearch,'String');
    if isempty(name)
        blks = blocks;
    else
        blks = blocks(contains(lower({blocks.name}),lower(name)));
    end
    block = blks(value);
    set(hparams,'Data', [{block.params.name}',{block.params.dialog}',{block.params.type}']);
    set(hname,'String', sprintf('%s (%s)',block.name,block.type));
    selected_block.Value = block;
end
function [] = select_table(~,ev,selected_params)
    selected_params.Value = ev.Indices(:,1);
end
function [] = generate(~,~,block,par)
    if isempty(block.Value), return, end
    GenerateClass(block.Value,par.Value);
end

