function [out] = ReadTable()
    % https://it.mathworks.com/help/simulink/slref/block-specific-parameters.html
    blocks = matsim.utils.handlevar([]);
    fid = fopen('blockparams.csv');
    
    try
        tline = fgetl(fid);
        while ischar(tline)
            fields = strsplit(tline,'@');
            if isempty(fields)
                % warning(['Invalid line: ', tline])
            elseif ~isempty(strfind(fields{1},'Block (Type)'))
                % Skip
            elseif length(fields) == 1        
                [~,nt]=regexp(fields{1},'(.*)\((.*)\)','match','tokens');            
                block = matsim.utils.handlevar(struct('params',struct('name',{},'dialog',{},'type',{})));
                blocks(end+1) = block; %#ok            
                if isempty(nt)
                    block.Value.name = strtrim(tline);
                    block.Value.type = '';
                else
                    block.Value.name = strtrim(nt{1}{1});
                    block.Value.type = strtrim(nt{1}{2});
                end
            elseif length(fields) == 3
                par = struct;
                par.name = strtrim(fields{1});
                par.dialog = strtrim(fields{2});
                par.type = strtrim(fields{3});
                block.Value.params(end+1) = par;
            else
                % warning(['Invalid line: ', tline])
            end
            tline = fgetl(fid);
        end
    catch ME    
        fclose(fid);
        warning(['Error on line: ', tline])
        error(ME.message)
    end
    
    out = [blocks.Value];
end

