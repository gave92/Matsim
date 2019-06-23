function blk = Abs(varargin)
%ABS Creates a simulink Abs block.
% Example:
%   input = Constant('var1');
%   blk = Abs(input,'Name','myAbs');
% 
%   See also UNARY_OPERATOR.

    p = inputParser;
    p.CaseSensitive = false;
    p.KeepUnmatched = true;
    addOptional(p,'b1',[],@(x) isnumeric(x) || isempty(x) || isa(x,'matsim.library.block'));
    parse(p,varargin{:})

    b1 = p.Results.b1;
    args = matsim.helpers.validateArgs(p.Unmatched);

    blk = matsim.library.unary_operator(b1,'ops','Abs',args{:});
end
