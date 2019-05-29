classdef block_input
    properties (Access = public)
        % Input block
        value
        % Source index port
        srcport
        % Port type
        type
    end
    
    methods
        function this = block_input(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addRequired(p,'value',@(x) isempty(x) || isa(x,'matsim.library.block'));
            addOptional(p,'srcport',1,@isnumeric);
            addOptional(p,'type','input',@ischar);
            parse(p,varargin{:})
            
            this.value = p.Results.value;
            this.srcport = p.Results.srcport;
            this.type = p.Results.type;
        end
    
        function h = handle(this)
            h = this.value.handle;
        end
        function p = get(this,prop)
            p = get(this.value.handle,prop);
        end
        function [] = set(this,prop,value,idx)
            this.value.set(prop,value,idx);
        end
    end
end

