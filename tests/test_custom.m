function [] = test_custom(sys)
%TEST_CUSTOM

    in = Constant(0);
    
    LowPass({},in);
    LowPass(in);
    LowPass(0,5,1.5);
    
    Sat();
    Sat(in,{},1.5);
    Sat({},-1,1);
    
end

