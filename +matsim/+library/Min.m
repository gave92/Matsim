function blk = Min(varargin)
%MIN Creates a simulink Min block.
% Example:
%   in1 = Constant('var1');
%   in2 = Constant('var2');
%   blk = Min(in1,in2,'name','myMin');
% 
%   See also BINARY_OPERATOR.

    p = inputParser;
    p.CaseSensitive = false;
    p.KeepUnmatched = true;
    addOptional(p,'b1',[],@(x) isnumeric(x) || isempty(x) || isa(x,'matsim.library.block'));
    addOptional(p,'b2',[],@(x) isnumeric(x) || isempty(x) || isa(x,'matsim.library.block'));
    parse(p,varargin{:})

    b1 = p.Results.b1;
    b2 = p.Results.b2;
    args = matsim.helpers.validateArgs(p.Unmatched);

    blk = matsim.library.binary_operator(b1,b2,'ops','MinMax','Function','Min','Inputs',mat2str(2),args{:});
end

