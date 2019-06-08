function [] = test_dynamics(sys)
%TEST_DYNAMICS

    import matsim.library.*

    in = Constant(0);
    
    Delay({},'SampleTime',0.1);
    Delay(in,'DelayLength',2);
    Delay('x0',1);
    
    Integrator();
    Integrator(in,'SampleTime',0.1);
    Integrator(in);
    
end

