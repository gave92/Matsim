function [] = test_dynamics(sys)
%TEST_DYNAMICS

    import matsim.library.*

    in = Constant(0);
    
    Delay({},'Ts',0.1);
    Delay(in,2);
    Delay('x0',1);
    
    Integrator();
    Integrator(in,'Ts',0.1);
    Integrator(in);
    
end

