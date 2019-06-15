classdef REF < block
%REF Creates a simulink From or Goto block
% Syntax:
%   blk = REF('TAG')
%     A FROM block with tag 'TAG' will be created.
%   blk = REF('TAG',INPUT)
%     If INPUT is specified a GOTO block will be created.
%     INPUT block will be connected to the block input port.
%     INPUT can be:
%       - an empty cell {}
%       - a matsim block
%       - a number
%     If INPUT is a number a Constant block with that value will
%     be created.
%   blk = REF('TAG',ARGS)
%     ARGS is an optional list of parameter/value pairs specifying simulink
%     block properties.
% 
% Example:
%   in1 = Constant(1);
%   REF('mySig',in1);
%   Scope(REF('mySig'));
% 
%   See also BLOCK.

    properties
        
    end
    
    methods
        function this = REF(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addRequired(p,'tag',@(x) isnumeric(x) || ischar(x));
            addOptional(p,'b1',{},@(x) isnumeric(x) || isempty(x) || isa(x,'block'));
            addParamValue(p,'parent','',@(x) ischar(x) || ishandle(x) || isa(x,'block') || isa(x,'simulation'));
            parse(p,varargin{:})

            inputs = {p.Results.b1};
            tag = p.Results.tag;
            parent = helpers.getValidParent(inputs{:},p.Results.parent);
            args = helpers.validateArgs(p.Unmatched);
            
            if isempty(parent)
                parent = gcs;
            end            
            
            if isempty(p.Results.b1)
                type = 'From';
            else
                type = 'Goto';
            end
            
            this = this@block('type',type,'parent',parent,args{:});
            this.set('ShowName','off');
            this.setInputs(inputs);
            
            if isnumeric(tag)
                tag = ['ref', mat2str(tag)];
            end
            this.set('GotoTag',tag);
            
            location = this.get('Position');
            location(3) = location(1)+max(40,10*length(tag));
            this.set('Position',location);           
        end       
    end   
end

