function [out] = LowPass(varargin)
%SAT Saturation block

    p = inputParser;
    p.CaseSensitive = false;
    % p.PartialMatching = false;
    p.KeepUnmatched = true;
    addOptional(p,'b1',{},@(x) isnumeric(x) || isempty(x) || isa(x,'block'));
    addOptional(p,'freq',1,@(x) isnumeric(x) || isempty(x) || isa(x,'block'));
    addParamValue(p,'gain',1,@(x) isnumeric(x) || isempty(x) || isa(x,'block'));
    addParamValue(p,'Ts',0,@(x) ischar(x) || isnumeric(x));
    addParamValue(p,'parent','',@(x) ischar(x) || ishandle(x) || isa(x,'block') || isa(x,'simulation'));
    parse(p,varargin{:})

    inputs = {p.Results.b1};
    freq = p.Results.freq;
    gain = p.Results.gain;    
    Ts = p.Results.Ts;
    parent = helpers.getValidParent(inputs{:},freq,gain,p.Results.parent);
    args = helpers.validateArgs(p.Unmatched);

    if isempty(parent)
        parent = gcs;
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
    
    % Set sampling time
    blk.setMaskParam('Ts',Ts);
    
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

