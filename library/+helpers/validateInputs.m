function out = validateInputs(input,parent)
%VALIDATEINPUTS Convert input to block_input

    if isempty(input)    
        out = block_input({});
    elseif iscell(input)
        out = cellfun(@(in) helpers.validateInputs(in,parent),input,'Uni',0);
    elseif isa(input,'block')
        out = block_input(input);
    elseif isa(input,'block_input')
        out = input;
    elseif isnumeric(input)
        out = block_input(Constant(input,'parent',parent));
    elseif strcmp(input.get('BlockType'),'Goto')
        out = block_input(REF(input.get('GotoTag')));
    else
        error('Invalid argument type')
    end

end
