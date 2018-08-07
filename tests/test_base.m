function [] = test_base(sys)
%TEST_BASE

    in = Constant(0);
    
    binary_operator({},in,'ops','MinMax','Inputs','2');
    binary_operator(in,'ops','MinMax','Inputs','2');
    binary_operator(0,1,'ops','MinMax','Inputs','2');
    
    unary_operator('ops','To Workspace');
    unary_operator(in,'ops','To Workspace','name','TEST NAME');
    unary_operator(0,'ops','To Workspace');
    
end

