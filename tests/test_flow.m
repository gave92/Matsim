function [] = test_flow(sys)
%TEST_FLOW

    in = Constant([0, 1, 2, 3]);
    
    r = REF('in',in);
    d = Demux(r,'outputs',[1,3]);
    m = Mux({d.outport(2),-1});
    f = IF(m>0,in,in(-1));
    s = Selector(f,'indices',[1,4],'width',4);
    w = Switch(s,0);
    g = Merge({w,{},s});
    
end

