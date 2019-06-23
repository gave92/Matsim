function s = isArgSpecified(p,arg)
%ISARGSPECIFIED User specified an argument

    s = ~any(strcmp(p.UsingDefaults,arg)) && (iscell(p.Results.(arg)) || ~isempty(p.Results.(arg)));

end

