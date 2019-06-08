function [] = test_flow(sys)
%TEST_FLOW

    import matsim.library.*

    in = Constant([0, 1, 2, 3]);
    in.outport(1,'name','CONSTANT')
    
    r = REF('in',in);
    d = Demux(r,'Outputs',[1,3]);
    m = Mux({d.outport(2)+1,-1});
    f = IF(m>0,in,in(-1));
    s = Selector(f,'Indices',[1,4],'InputPortWidth',4);
    w = Switch(s,0);
    g = Merge({w,{},s});
    g.outport(1,'name','MERGE')
    
    bc = BusCreator({r,g,w});
    bs = BusSelector(bc,'OutputSignals',{'CONSTANT','MERGE'});
    Terminator(bs.outport(1))
    Scope(bs.outport(2))
    
end

