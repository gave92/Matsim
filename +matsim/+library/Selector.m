classdef Selector < matsim.library.unary_operator
%SELECTOR Creates a simulink Selector block.
% Syntax:
%   blk = Selector(INPUT,'Indices',INDICES,'InputPortWidth',PORTWIDTH);
%     The block specified as INPUT will be connected to the input port of this block.
%     INPUT can be:
%       - an empty cell {}
%       - a matsim block
%       - a number
%     If INPUT is a number a Constant block with that value will
%     be created.
%     INDICES parameter selects which elements to extract from the input
%     vector.
%     PORTWIDTH is the size of the input vector.
% 
% Example:
%   in1 = Constant([1,2,3]);
%   Selector(in1,'Indices',[1,3],'InputPortWidth',3);
% 
%   See also UNARY_OPERATOR.

    properties
        
    end
    
    methods
        function this = Selector(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            p.KeepUnmatched = true;
            addOptional(p,'b1',[],@(x) isnumeric(x) || isempty(x) || isa(x,'matsim.library.block'));
            addParamValue(p,'Indices',[1,3],@(x) isnumeric(x));
            addParamValue(p,'InputPortWidth',3,@(x) isnumeric(x));
            parse(p,varargin{:})
            
            b1 = p.Results.b1;
            Indices = p.Results.Indices;
            InputPortWidth = p.Results.InputPortWidth;
            args = matsim.helpers.validateArgs(p.Unmatched);
            
            this = this@matsim.library.unary_operator(b1,'BlockName','Selector',args{:});
            this.set({'NumberOfDimensions','1','IndexOptions','Index vector (dialog)','InputPortWidth',mat2str(InputPortWidth),'Indices',mat2str(Indices)})
        end
    end
    
end

