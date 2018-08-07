classdef Lookup1D < unary_operator
    properties
        
    end
    
    methods
        function this = Lookup1D(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;            
            addOptional(p,'b1',{},@(x) isnumeric(x) || isempty(x) || isa(x,'block') || isa(x,'block_input'));
            addParamValue(p,'table','',@(x) isnumeric(x) || ischar(x));
            addParamValue(p,'breakpoints','',@(x) isnumeric(x) || ischar(x));
            parse(p,varargin{:})
            
            b1 = p.Results.b1;
            table = p.Results.table;
            breakpoints = p.Results.breakpoints;
            args = helpers.unpack(p.Unmatched);
            
            this = this@unary_operator(b1,'ops','1-D Lookup Table',args{:});
            this.set('ExtrapMethod','Clip')
            this.set('UseLastTableValue','on')

            if ischar(table)
                this.set('Table',table)
            elseif isnumeric(table)
                this.set('Table',mat2str(table))
            end
            if ischar(breakpoints)
                this.set('BreakpointsForDimension1',breakpoints)
            elseif isnumeric(breakpoints)
                this.set('BreakpointsForDimension1',mat2str(breakpoints))
            end
        end
    end
    
end

