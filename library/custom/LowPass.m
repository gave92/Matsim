function [out] = LowPass(varargin)
%SAT Saturation block

    p = inputParser;
    p.CaseSensitive = false;
    % p.PartialMatching = false;
    p.KeepUnmatched = true;
    addOptional(p,'b1',{},@(x) isnumeric(x) || isempty(x) || isa(x,'block') || isa(x,'block_input'));
    addOptional(p,'freq',1,@(x) isnumeric(x) || isempty(x) || isa(x,'block') || isa(x,'block_input'));
    addOptional(p,'gain',1,@(x) isnumeric(x) || isempty(x) || isa(x,'block') || isa(x,'block_input'));
    addParamValue(p,'parent','',@(x) ischar(x) || ishandle(x) || isa(x,'block') || isa(x,'simulation'));
    parse(p,varargin{:})

    inputs = {p.Results.b1};
    freq = p.Results.freq;
    gain = p.Results.gain;
    parent = helpers.getValidParent(inputs{:},freq,gain,p.Results.parent);
    args = helpers.unpack(p.Unmatched);

    % validateattributes(parent,{'char'},{'nonempty'},'','parent')
    if isempty(parent)
        parent = gcs;
    end    
    for i=1:length(inputs)
        if isempty(inputs{i})
            continue
        end
        if isnumeric(inputs{i})
            inputs{i} = block_input(Constant(inputs{i},'parent',parent));
        end
        if strcmp(inputs{i}.get('BlockType'),'Goto')
            inputs{i} = block_input(REF(inputs{i}.get('GotoTag')));
        end
    end
    
    mask = false;
    if isnumeric(freq) && isnumeric(gain)
        s = Subsystem(inputs);
        s.in(1,'name','Input');
        parent = s;
        mask = true;
    end
    if isnumeric(freq)
        freq = Constant(freq,'parent',parent);
    end
    if isnumeric(gain)
        gain = Constant(gain,'parent',parent);
    end

    if getversion() >= 2015
        blk = block('model','Blocks_2015b','type','Adaptive LP Filter','parent',parent,args{:});
    else
        blk = block('model','Blocks_2011b','type','Adaptive LP Filter','parent',parent,args{:});
    end
    
    if mask
        blk.setInputs({s.in(1),freq,gain})
        s.set('name',sprintf('Filter @ %dHz',p.Results.freq));
        s.out(1,blk,'name','Out');
        out = s;
    else
        blk.setInputs({inputs{:},freq,gain})
        out = blk;
    end
end

