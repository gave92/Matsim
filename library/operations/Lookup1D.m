classdef Lookup1D < unary_operator
%LOOKUP1D Creates a simulink 1-D Lookup Table block.
% Syntax:
%   blk = Lookup1D(INPUT,'Table',TABLE,'breakpoints',BREAKPOINTS);
%     The block specified as INPUT will be connected to the input port of this block.
%     TABLE is a numeric array or string (variable name) to be set as table
%     data.
%     BREAKPOINTS is a numeric array or string (variable name) to be set as
%     table x-data.
%
% Example:
%   in1 = FromWorkspace('var1');
%   blk = Lookup1D(in1,'Table',rand(1,4),'breakpoints',[1:4]);
% 
%   See also UNARY_OPERATOR.

    properties
        
    end
    
    methods
        function this = Lookup1D(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;            
            addOptional(p,'b1',{},@(x) isnumeric(x) || isempty(x) || isa(x,'block'));
            addParamValue(p,'table','',@(x) isnumeric(x) || ischar(x));
            addParamValue(p,'breakpoints','',@(x) isnumeric(x) || ischar(x));
            parse(p,varargin{:})
            
            b1 = p.Results.b1;
            table = p.Results.table;
            breakpoints = p.Results.breakpoints;
            args = helpers.validateArgs(p.Unmatched);
            
            this = this@unary_operator(b1,'ops','1-D Lookup Table',args{:});
            this.set('ExtrapMethod','Clip')
            this.set('UseLastTableValue','on')

            this.set('Table',table)
            this.set('BreakpointsForDimension1',breakpoints)
        end
    end
    
end

