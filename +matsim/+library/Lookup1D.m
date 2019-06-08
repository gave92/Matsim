classdef Lookup1D < matsim.library.unary_operator
    properties
        
    end
    
    methods
        function this = Lookup1D(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;            
            addOptional(p,'b1',{},@(x) isnumeric(x) || isempty(x) || isa(x,'matsim.library.block'));
            addParamValue(p,'Table','',@(x) isnumeric(x) || ischar(x));
            addParamValue(p,'breakpoints','',@(x) isnumeric(x) || ischar(x));
            parse(p,varargin{:})
            
            b1 = p.Results.b1;
            Table = p.Results.Table;
            breakpoints = p.Results.breakpoints;
            args = matsim.helpers.validateArgs(p.Unmatched);
            
            this = this@matsim.library.unary_operator(b1,'ops','1-D Lookup Table',args{:});
            this.set('ExtrapMethod','Clip')
            this.set('UseLastTableValue','on')

            this.set('Table',Table)
            this.set('BreakpointsForDimension1',breakpoints)
        end
    end
    
end

