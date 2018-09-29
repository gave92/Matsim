function [] = test_base(sys)
%TEST_BASE
    
    in = Constant(0);
    
    s = Scope({[{},in],0});
    t = Terminator();
    w = ToWorkspace(in,'varname','TEST_NAME');
    
end

