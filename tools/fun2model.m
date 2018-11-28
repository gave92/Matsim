function [out] = fun2model(varargin)
%FUN2MODEL Function handle to simulink model

    p = inputParser;
    p.CaseSensitive = true;
    % p.PartialMatching = false;
    p.KeepUnmatched = true;
    addRequired(p,'fun',@(x) isa(x,'function_handle'));
    addParamValue(p,'model','',@(x) ischar(x) || ishandle(x) || isa(x,'block') || isa(x,'simulation'));
    addParamValue(p,'goto',false,@islogical);
    parse(p,varargin{:})

    fun = p.Results.fun;
    goto = p.Results.goto;
    model = helpers.getBlockPath(p.Results.model);
    args = helpers.unpack(p.Unmatched);

    if isempty(model)
        model = simulation.load('untitled');
        % model.clear()
        model.show()
    end
    
    funstr = func2str(fun);
    [~,tok] = regexp(funstr,'@\((.*)\)','match','tokens');
    symb_names = strsplit(tok{1}{1},',');
    
    subsystem = Subsystem('parent',model,args{:});
    set_param(0,'CurrentSystem',subsystem.handle)
    for e=1:length(symb_names)
        eval([symb_names{e}, '=subsystem.in(e,''name'',symb_names{e});'])
        if (goto)
            eval([symb_names{e}, sprintf('=REF(''%s'', %s);',symb_names{e},symb_names{e})])
        end
    end
    
    [~,tok] = regexp(funstr,'(@\(.*\))','match','tokens');
    exprstr = strrep(funstr,tok{1}{1},'');
    res = eval(exprstr);
    subsystem.out(1,res,'name','res')
    
    simlayout(subsystem.handle)
    out = subsystem;
end

