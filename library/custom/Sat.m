function [blk] = Sat(varargin)
%SAT Saturation block

    p = inputParser;
    p.CaseSensitive = false;
    % p.PartialMatching = false;
    p.KeepUnmatched = true;
    addOptional(p,'b1',{},@(x) isnumeric(x) || isempty(x) || isa(x,'block'));
    addOptional(p,'minv',0,@(x) isnumeric(x) || isempty(x) || isa(x,'block'));
    addOptional(p,'maxv',1,@(x) isnumeric(x) || isempty(x) || isa(x,'block'));
    addParamValue(p,'parent','',@(x) ischar(x) || ishandle(x) || isa(x,'block') || isa(x,'simulation'));
    parse(p,varargin{:})

    inputs = {p.Results.b1};
    minv = p.Results.minv;
    maxv = p.Results.maxv;
    parent = helpers.getValidParent(inputs{:},minv,maxv,p.Results.parent);
    args = helpers.validateArgs(p.Unmatched);

    % validateattributes(parent,{'char'},{'nonempty'},'','parent')
    if isempty(parent)
        parent = gcs;
    end
    
    if isnumeric(minv)
        minv = Constant(minv,'parent',parent);
    end
    if isnumeric(maxv)
        maxv = Constant(maxv,'parent',parent);
    end

    if getversion() >= 2015
        blk = block('model','Blocks_2015b','type','Saturation','parent',parent,args{:});
    else
        blk = block('model','Blocks_2011b','type','Saturation','parent',parent,args{:});
    end
    
    blk.setInputs({maxv,minv,inputs{:}})

end

