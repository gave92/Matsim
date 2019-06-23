function [] = test_subsystems(sys)
%TEST_SUBSYSTEM

    import matsim.library.*

    v1 = REF('IN',0);
    s = Subsystem({{},v1},'name','TEST');
    s.enable(1);
    s.in(3,1.5);
    s.in(2,'name','INPUT');
    s.out(1,s.in(1)+s.in(3));
    s.out(2,{});
    s.out(2,'name','OUTPUT');
    s.trigger(Constant(-1));
    Terminator(s)
    Scope(s.outport(2))
    s.in(3,{});
    
end

