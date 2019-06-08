function [] = test_operations(sys)
%TEST_OPS

    import matsim.library.*

    in = Constant(1);
    
    r = Abs(Cos().^2+Sign(in).*Sin(Constant('pi')).^2);
    l1 = Lookup1D('Table',[0,0],'breakpoints',[0 1]);
    l2 = Tan(Atan(Lookup2D(r,0,'Table','TABLE','breakpoints1',[1 2 3],'breakpoints2','[0 0.1 0.2 0.3]')));
    g = Gain(Max(0,{}),'Gain',-1).*Min(l1,l2);
    
end

