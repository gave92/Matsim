function [] = test_operations(sys)
%TEST_OPS

    in = Constant(1);
    
    r = Abs(Cos().^2+Sign(in).*Sin(Constant('pi')).^2);
    l1 = Lookup1D('table',[0,0],'breakpoints',[0 1]);
    l2 = Lookup2D(r,0);
    g = Gain(Max(0,{}),'value',-1).*Min(l1,l2);
    
end

