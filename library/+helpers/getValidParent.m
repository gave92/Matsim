function parent = getValidParent(varargin)
%GETVALIDPARENT Find a valid block parent in argument list
%   parent = getValidParent(obj1,obj2,obj3,...)
%   Parameters:
%       A list containing objects of type:
%           "simulation", "block", "handle", "string"

    parent = '';
    for i = 1:length(varargin)
        if isa(varargin{i},'simulation')
            parent = get(varargin{i},'Name');
            return;
        elseif isa(varargin{i},'block')
            parent = get(varargin{i},'Path');
            return;
        elseif isa(varargin{i},'block_input')
            parent = get(varargin{i},'Path');
            return;
        elseif ishandle(varargin{i})
            if strcmp(get(varargin{i},'type'),'block_diagram')
                parent = get(varargin{i},'Name');
            elseif strcmp(get(varargin{i},'type'),'block')
                parent = get(varargin{i},'Path');
            end
            return;
        elseif ischar(varargin{i})
            parent = varargin{i};
            return;
        end
    end
end
