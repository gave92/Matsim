function [] = test_base(sys)
%TEST_BASE

    import matsim.library.*

    in = Constant(0);
    
    binary_operator({},in,'BlockName','MinMax','Inputs','2');
    binary_operator(in,'BlockName','MinMax','Inputs','2');
    binary_operator(0,1,'BlockName','MinMax','Inputs','2');
    
    unary_operator('BlockName','To Workspace');
    unary_operator(in,'BlockName','To Workspace','name','TEST NAME');
    unary_operator(0,'BlockName','To Workspace');
    
end

