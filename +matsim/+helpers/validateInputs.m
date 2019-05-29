function out = validateInputs(input,parent)
%VALIDATEINPUTS Convert input to block_input

    if isempty(input)    
        out  = matsim.library.block_input({});
    elseif iscell(input)
        out = cellfun(@(in) matsim.helpers.validateInputs(in,parent),input,'Uni',0);   
    elseif isnumeric(input)
        out  = matsim.library.block_input(matsim.library.Constant(input,'parent',parent));
    elseif isa(input,'matsim.library.block') || isa(input,'matsim.library.block_input')
        if strcmp(input.get('BlockType'),'Goto')
            out  = matsim.library.block_input(matsim.library.REF(input.get('GotoTag')));
        elseif isa(input,'matsim.library.block')
            out  = matsim.library.block_input(input,input.outport);
        elseif isa(input,'matsim.library.block_input')
            out = input;
        end
    else
        error('Invalid argument type')
    end

end
