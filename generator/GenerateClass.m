function [fig] = GenerateClass(block,par)
    
    selected_inputs = matsim.utils.handlevar([]);

    if isempty(par)
        params = [];
    else
        params = block.params(par);
    end
    
    fig = figure('Units','norm','Position',[0.3 0.2 0.4 0.6],'Toolbar','none');    
    hcontent1 = uipanel('Parent',fig,'Position',[0 0.95 1 0.05],'bordertype','none');
    hpanel = uiflowcontainer('v0','Units','norm','Position',[0 0 1 0.95],'FlowDirection','lefttoright','Parent', fig);
    hcontent2 = uipanel('Parent',hpanel);
    hcontent3 = uipanel('Parent',hpanel);
    set(hcontent2,'WidthLimits',[200,200])
    bounds1 = getpixelposition(hcontent1);
    bounds2 = getpixelposition(hcontent2);
    bounds3 = getpixelposition(hcontent3);
    
    hname = uicontrol('Style','text','Parent',hcontent1,...
        'FontSize',12,'HorizontalAlignment','left', ...
        'String',sprintf('%s (%s)',block.name,block.type),...
        'Units','norm','Position', [0 0 1 1]);
    hclass = uicontrol('Style','edit','Parent',hcontent3,...
        'FontSize',12,'HorizontalAlignment','left', ...
        'String','','Max',2,...
        'Units','norm','Position', [0 0 1 1]);
    
    jScrollPane = findjobj(hclass);    
    cbStr = sprintf('set(gcbo,''HorizontalScrollBarPolicy'',32)');
    hjScrollPane = handle(jScrollPane,'CallbackProperties');
    set(hjScrollPane,'ComponentResizedCallback',cbStr);
    set(jScrollPane,'HorizontalScrollBarPolicy',32);
    jViewPort = jScrollPane.getViewport;
    jEditbox = jViewPort.getComponent(0);
    jEditbox.setWrapping(false);

    h1 = uicontrol('Style','text','Parent',hcontent2,...
        'FontSize',10,'HorizontalAlignment','left', ...
        'String','Number of inputs',...
        'Units','norm','Position', [0 0.95 1 0.05]);
    hinputs = uicontrol('Style','popupmenu','Parent',hcontent2,...
        'FontSize',10,'HorizontalAlignment','left', ...
        'String',{'0','1','2','Any'},...
        'Units','norm','Position', [0 0.9 1 0.05]);
    hgo = uicontrol('Style','pushbutton','Parent',hcontent2,...
        'FontSize',10,'HorizontalAlignment','left', ...
        'String','Generate',...
        'Units','norm','Position', [0 0.05 1 0.05]);
    hsave = uicontrol('Style','pushbutton','Parent',hcontent2,...
        'FontSize',10,'HorizontalAlignment','left', ...
        'String','Save',...
        'Units','norm','Position', [0 0 1 0.05]);
    
    set(hinputs,'Callback',{@selected_popup,selected_inputs})
    set(hgo,'Callback',{@generate,block,params,hclass,selected_inputs})
    set(hsave,'Callback',{@save,block,hclass})
end

function [] = save(~,~,block,hclass)
    s = get(hclass,'String');
    txt = '';
    for i = 1:size(s,1)
        ln = regexprep(s(i,:),'\r|\n','');
        ln = regexprep(ln,'[ \t]+$','');
        txt = [txt, sprintf('%s\n',ln)];
    end

    mkdir('classes')
    name = regexprep(block.name,'[^a-zA-z]','');
    fileID = fopen(fullfile('classes',[name,'.m']),'w');
    fprintf(fileID,'%s',txt);
    fclose(fileID);
end
function [] = selected_popup(src,~,selected_popup)
    selected_popup.Value = src.Value;
end
function [] = generate(~,~,block,params,hclass,selected_inputs)
    num_inputs = selected_inputs.Value;
    if isempty(num_inputs), return, end
    
    name = regexprep(block.name,'[^a-zA-z]','');
    paradd = ''; parres = ''; parset = '';
    for i = 1:length(params)
        parname = regexprep(params(i).name,'[^a-zA-z]','');
        paradd = [paradd, repmat(' ',1,12), sprintf('addParamValue(p,''%s'',%s,@(x) ischar(x) || isnumeric(x));\n',parname,'{}')];
        parres = [parres, repmat(' ',1,12), sprintf('%s = p.Results.%s;\n',parname,parname)];        
        parset = [parset, repmat(' ',1,12), sprintf('this.set(''%s'',%s);\n',params(i).name,parname)];
    end
    
    switch num_inputs
        case 1
            template = fileread('source.txt');
            template = sprintf(template,name,upper(name),name,name,name,name,paradd,parres,'simulink',block.name,parset);
        case 2
            template = fileread('unary.txt');
            template = sprintf(template,name,upper(name),name,name,name,name,paradd,parres,block.name,parset);
        case 3
            template = fileread('binary.txt');
            template = sprintf(template,name,upper(name),name,name,name,name,paradd,parres,block.name,parset);
        case 4
            template = fileread('multiple.txt');
            template = sprintf(template,name,upper(name),name,name,name,name,paradd,parres,'simulink',block.name,parset);
    end
    set(hclass,'String',template)
    jhEdit = findjobj(hclass);
    jEdit = jhEdit.getComponent(0).getComponent(0);
    jEdit.setCaretPosition(0);
end

