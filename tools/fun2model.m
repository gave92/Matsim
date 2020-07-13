function [out] = fun2model(varargin)
%FUN2MODEL Function handle to simulink model

    import matsim.library.*

    p = inputParser;
    p.CaseSensitive = true;
    p.KeepUnmatched = true;
    addRequired(p,'fun',@(x) isa(x,'function_handle'));
    addParamValue(p,'model','',@(x) ischar(x) || ishandle(x) || isa(x,'matsim.library.block') || isa(x,'matsim.library.simulation'));
    addParamValue(p,'goto',false,@islogical);
    parse(p,varargin{:})

    fun = p.Results.fun;
    goto = p.Results.goto;
    model = matsim.helpers.getBlockPath(p.Results.model);
    args = matsim.helpers.unpack(p.Unmatched);

    if isempty(model)
        model = simulation.load('untitled');
        % model.clear()
        model.show()
    end
    
    funstr = func2str(fun);
    [~,tok] = regexp(funstr,'@\(([\w|,]*)\)','match','tokens');
    symb_names = strtrim(strsplit(tok{1}{1},','));
    
    subsystem = Subsystem('parent',model,args{:});
    set_param(0,'CurrentSystem',subsystem.handle)
    for e=1:length(symb_names)
        eval([symb_names{e}, '=subsystem.in(e,''name'',symb_names{e});'])
        if (goto)
            eval([symb_names{e}, sprintf('=REF(''%s'', %s);',symb_names{e},symb_names{e})])
        end
    end
    
    [~,tok] = regexp(funstr,'(@\([\w|,]*\))','match','tokens');
    exprstr = strrep(funstr,tok{1}{1},'');
    [~,~,pos] = regexp(exprstr,'(\w+\()','match','tokens'); % try use matsim functions
    exprstr(pos) = upper(exprstr(pos));
    res = eval(exprstr);
    subsystem.out(1,res,'name','res')
    
    matsim.builder.graphviz.simlayout(subsystem.handle,'Recursive',true)
    out = subsystem;
end

