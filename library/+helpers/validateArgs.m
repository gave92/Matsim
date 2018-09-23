function out = validateArgs(arg)
%VALIDATEARGS Convert argument list to char

    if ischar(arg)
        out = arg;
    elseif isnumeric(arg) || islogical(arg)
        out = mat2str(arg);
    elseif iscell(arg)
        out = cellfun(@helpers.validateArgs,arg,'Uni',0);
    elseif isstruct(arg)
        out = helpers.validateArgs(helpers.unpack(arg));
    else
        error('Invalid argument type')
    end

end
