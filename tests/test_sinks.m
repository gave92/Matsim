function [] = test_base(sys)
%TEST_BASE
    
    import matsim.library.*

    in = Constant(0);
    
    s = Scope({[{},in],0});
    t = Terminator();
    w = ToWorkspace(in,'VariableName','TEST_NAME');
    
end

