function match = findBlock(sys,varargin)
%FINDBLOCK Find block in simulink system
%   match = findBlock(sys,Name,Value)
%   Parameters:
%       sys, simulink system handle or name
%       (optional) BlockName, name of block
%       (optional) BlockType, name of block
%       (optional) SearchDepth

    % Backup current system
    current_system = gcs;

    p = inputParser;
    p.CaseSensitive = false;
    % p.PartialMatching = false;
    p.KeepUnmatched = true;
    addRequired(p,'sys',@(x) isnumeric(x) && ishandle(x) || ischar(x));
    addParamValue(p,'Exact',true,@islogical);
    addParamValue(p,'BlockName','',@ischar);
    addParamValue(p,'BlockType','',@ischar);
    addParamValue(p,'SearchDepth',-1,@isnumeric);
    parse(p,sys,varargin{:})

    sys = p.Results.sys;
    search_depth = p.Results.SearchDepth;
    block_name = p.Results.BlockName;
    block_type = p.Results.BlockType;
    exact = p.Results.Exact;
    other = matsim.helpers.unpack(p.Unmatched);
        
    try
        load_system(sys);
        % set_param(sys,'Lock','off')
    catch
    end

    if matsim.utils.getversion() >= 2012
        args = {'CaseSensitive','off','RegExp','on','IncludeCommented','on','Type','block'};
    else
        args = {'CaseSensitive','off','RegExp','on','Type','block'};
    end
    if search_depth >= 0
        args = ['SearchDepth',mat2str(search_depth),args];
    end
    if ~isempty(block_type)
        args = [args,'BlockType',['^',escape(block_type),'$']];
    end
    if ~isempty(block_name)
        if exact
            args = [args,'name',['^',escape(block_name),'$']];
        else
            args = [args,'name',escape(block_name)];
        end        
    end
    args = [other, args];
    
    % Find match in system    
    match = find_system(sys,args{:});
    
    % Restore current system
    set_param(0,'CurrentSystem',current_system)
end

function esc = escape(query)
    % Escape regex query
    esc = regexprep(query,'\[|\]|\(|\)|\*|\+|\?|\.|\|','\\$&');
end

