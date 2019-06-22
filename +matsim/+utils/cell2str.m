function string = cell2str(celldata)
%CELL2STR Convert a 2-D cell array of strings to a string in MATLAB syntax.
%   STR = CELL2STR(CELLSTR) converts the 2-D cell-string CELLSTR to a 
%   MATLAB string so that EVAL(STR) produces the original cell-string.
%   Works as corresponding MAT2STR but for cell array of strings instead of 
%   scalar matrices.
%
%   Example
%       cellstr = {'U-234','Th-230'};
%       cell2str(cellstr) produces the string '{''U-234'',''Th-230'';}'.
%
%   See also MAT2STR, STRREP, CELLFUN, EVAL.
%   Developed by Per-Anders Ekstr?m, 2003-2007 Facilia AB.
    if nargin~=1
        error('CELL2STR:Nargin','Takes 1 input argument.');
    end
    if isempty(celldata)
        string = '{}';
        return
    end
    if ischar(celldata)
        string = ['''' celldata ''''];
        return
    end
    if ~isvector(celldata)
        error('CELL2STR:OneDInput','Input cell array must be 1-D.');
    end
    for i=1:length(celldata)
        if ischar(celldata{i})
            celldata{i} = ['''' celldata{i} ''','];
        else
            celldata{i} = [mat2str(celldata{i}) ','];
        end
    end
    celldata = celldata';
    string = ['{' celldata{:} '}'];
end
