function out = unpack(inStruct)
%UNPACK Struct to cell array
%   C = unpack(s)
%   The output cell array contains both fieldnames and values of the struct

    tmp = cellfun(@(x) {x, inStruct.(x)},fieldnames(inStruct),'Uni',0);
    if isempty(tmp)
        out = {};
    else
        out = [tmp{:}];
    end
    
end

