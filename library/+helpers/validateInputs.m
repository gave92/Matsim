function out = validateInputs(input,parent)
%VALIDATEINPUTS Convert input to block

    if isempty(input)
        out = {};
    elseif isnumeric(input)
        out = block_input(Constant(input,'parent',parent));
    elseif strcmp(input.get('BlockType'),'Goto')
        out = block_input(REF(input.get('GotoTag')));
    elseif iscell(input)
        out = cellfun(@helpers.validateInputs,arg,'Uni',0);
    else
        error('Invalid argument type')
    end

end
