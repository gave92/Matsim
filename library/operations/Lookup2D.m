classdef Lookup2D < binary_operator
%LOOKUP2D Creates a simulink 2-D Lookup Table block.
% Syntax:
%   blk = Lookup2D(IN1,IN2,'Table',TABLE,'breakpoints1',BREAKPOINTS1,'breakpoints2',BREAKPOINTS2);
%     The blocks specified as IN1 and IN2 will be connected to the input
%     ports of this block.
%     TABLE is a numeric array or string (variable name) to be set as table
%     data.
%     BREAKPOINTS1 is a numeric array or string (variable name) to be set as
%     table x-data.
%     BREAKPOINTS2 is a numeric array or string (variable name) to be set as
%     table y-data.
%
% Example:
%   in1 = FromWorkspace('var1');
%   in2 = FromWorkspace('var2');
%   blk = Lookup2D(in1,in2,'Table',rand(3,4),'breakpoints1',[1:3],'breakpoints2',[1:4]);
% 
%   See also BINARY_OPERATOR.

    properties
        
    end
    
    methods
        function this = Lookup2D(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;            
            addOptional(p,'b1',{},@(x) isnumeric(x) || isempty(x) || isa(x,'block'));
            addOptional(p,'b2',{},@(x) isnumeric(x) || isempty(x) || isa(x,'block'));
            addParamValue(p,'table','',@(x) isnumeric(x) || ischar(x));
            addParamValue(p,'breakpoints1','',@(x) isnumeric(x) || ischar(x));
            addParamValue(p,'breakpoints2','',@(x) isnumeric(x) || ischar(x));
            parse(p,varargin{:})
            
            b1 = p.Results.b1;
            b2 = p.Results.b2;
            table = p.Results.table;
            breakpoints1 = p.Results.breakpoints1;
            breakpoints2 = p.Results.breakpoints2;
            args = helpers.validateArgs(p.Unmatched);
            
            this = this@binary_operator(b1,b2,'ops','2-D Lookup Table',args{:});
            this.set('ExtrapMethod','Clip')
            this.set('UseLastTableValue','on')

            this.set('Table',table)
            this.set('BreakpointsForDimension1',breakpoints1)
            this.set('BreakpointsForDimension2',breakpoints2)
        end
    end
    
end

