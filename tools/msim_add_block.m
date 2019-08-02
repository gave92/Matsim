function [ blk ] = msim_add_block(dest,varargin)
%MSIM_ADD_BLOCK Add block to simulink model.
% Syntax:
%   blk = msim_add_block(PARENT,'BlockName',NAME);
%     PARENT is the path in which add the block (e.g. "gcs")
%     NAME is the name (prop: "Name") of the block to be created.
%   blk = block(PARENT,'BlockType',TYPE);
%     PARENT is the path in which add the block (e.g. "gcs")
%     TYPE is the type (prop: "BlockType") of the block to be created.
%   blk = block(PARENT,'Library',MODEL,'BlockType',TYPE,ARGS);
%     MODEL is the name of the library containing the desired block.
%     ARGS is an optional list of parameter/value pairs specifying simulink
%     block properties.
% 
% Example:
%   blk = msim_add_block(gcs,'blocktype','Constant','name','TEST')

    p = inputParser;
    p.CaseSensitive = false;
    p.KeepUnmatched = true;
    addRequired(p,'dest',@(x) get_param(x,'handle'));
    addParamValue(p,'Library','simulink',@ischar);
    addParamValue(p,'BlockName','',@ischar);
    addParamValue(p,'BlockType','',@ischar);
    addParamValue(p,'UseMatsim',false,@islogical);
    parse(p,dest,varargin{:})
    
    model = p.Results.Library;
    use_matsim = p.Results.UseMatsim;
    block_name = p.Results.BlockName;
    block_type = p.Results.BlockType;
    args = matsim.helpers.validateArgs(p.Unmatched);

    if use_matsim
        blk = matsim.library.block('BlockName',block_name,'BlockType',block_type,'Parent',dest,'Model',model,args{:});
    else
        % Create block
        match = matsim.helpers.findBlock(model,'BlockName',block_name,'BlockType',block_type);
        if isempty(match)
            match = matsim.helpers.findBlock(model,'BlockName',block_name,'BlockType',block_type,'LookUnderMasks','all');
        end
        if ~isempty(match)
            blk = add_block(match{1},strjoin({dest,get_param(match{1},'name')},'/'),'MakeNameUnique','on',args{:});
        else
            error('Could not find matching block.')
        end
    end
end
