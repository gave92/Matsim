classdef Terminator < matsim.library.unary_operator
%TERMINATOR Creates a simulink Terminator block.
% Example:
%   input = Demux();
%   blk = Terminator(input.outport(2),'Name','myTerminator');
% 
%   See also UNARY_OPERATOR.

    properties
        
    end
    
    methods
        function this = Terminator(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            p.KeepUnmatched = true;
            addOptional(p,'b1',[],@(x) isnumeric(x) || isempty(x) || isa(x,'matsim.library.block'));
            parse(p,varargin{:})

            b1 = p.Results.b1;
            args = matsim.helpers.validateArgs(p.Unmatched);

            this = this@matsim.library.unary_operator(b1,'ops','Terminator',args{:});
        end
    end
    
end

