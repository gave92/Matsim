classdef block < handle
    properties (Access = private)
        % Handle to simulink block
        simBlock
        % Handles to input blocks
        simInputs
    end
    
    methods
        function this = block(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addParamValue(p,'type','',@ischar);
            addParamValue(p,'model','simulink',@ischar);
            addParamValue(p,'parent','',@(x) ischar(x) || ishandle(x) || isa(x,'block') || isa(x,'simulation'));
            parse(p,varargin{:})
            
            type = p.Results.type;
            model = p.Results.model;
            strParent = helpers.getBlockPath(p.Results.parent);            
            args = helpers.unpack(p.Unmatched);
            
            % validateattributes(type,{'char'},{'nonempty'},'','type')
            % validateattributes(strParent,{'char'},{'nonempty'},'','parent')
            if isempty(strParent)
                strParent = gcs;
            end
            
            if any(strcmp(args,'name'))
                % Find existing block
                name = p.Unmatched.name;
                match = helpers.findBlock(strParent,'BlockName',name,'SearchDepth',1);
                if ~isempty(match)
                    this.simBlock = getSimulinkBlockHandle(match);
                    blk = this.getUserData('block');
                    if ~isempty(blk)
                        % Block was a MATSIM block, reuse
                        this = blk;
                    else
                        % Block was a SIMULINK block
                        this.setUserData('block',this);
                    end
                    this.setUserData('created',false)
                    return;
                end
            end
            
            % Create block
            match = helpers.findBlock(model,'BlockName',type);
            if ~isempty(match)
                this.simBlock = add_block(match{1},strjoin({strParent,type},'/'),'MakeNameUnique','on',args{:});
                this.setUserData('block',this)
                this.setUserData('created',true)
                % Set position to far right
                blockSizeRef = this.get('position');
                this.set('position',[1e4, 0, 1e4+blockSizeRef(3)-blockSizeRef(1), blockSizeRef(4)-blockSizeRef(2)])
            else
                error('Invalid block name')
            end
        end
    
        function in = getInputs(this)
            in = this.simInputs;
        end
        function out = outport(this,index)
            out = block_input(this,index);
        end
        function varargout = setInputs(this,varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addRequired(p,'value',@(x) iscell(x) && all(cellfun(@(c) isempty(c) || isa(c,'block') || isa(c,'block_input'),x)));
            parse(p,varargin{:})
            
            value = p.Results.value;
            for i=1:length(value)
                if isempty(value{i})
                    tmp = block_input({});
                elseif ~isa(value{i},'block_input')
                    tmp = block_input(value{i});
                else
                    tmp = value{i};
                end
                this.simInputs{i} = tmp;
            end
            if nargout == 1
                varargout{1} = this;
            end
        end
        function varargout = setInput(this,varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addRequired(p,'value',@(x) isempty(x) || isa(x,'block') || isa(x,'block_input'));
            addRequired(p,'index',@isnumeric);
            addParamValue(p,'srcport',1,@isnumeric);
            addParamValue(p,'type','input',@ischar);
            parse(p,varargin{:})
            
            value = p.Results.value;
            type = p.Results.type;
            index = p.Results.index;
            srcport = p.Results.srcport;
            
            if isempty(value)
                this.simInputs{index} = block_input({},srcport,type);
            elseif ~isa(value,'block_input')
                this.simInputs{index} = block_input(value,srcport,type);
            else
                value.type = type;
                this.simInputs{index} = value;
            end            
            if nargout == 1
                varargout{1} = this;
            end
        end
        
        function p = getUserData(this,prop)
            data = get(this.simBlock,'UserData');
            if ~isempty(data) && isfield(data,prop)
                p = data.(prop);
            else
                p = [];
            end
        end
        function [] = setUserData(this,prop,value)
            data = get(this.simBlock,'UserData');
            data.(prop) = value;
            set(this.simBlock,'UserData',data);
        end
        
        function h = handle(this)
            h = this.simBlock;
        end
        function p = get(this,prop)
            p = get(this.simBlock,prop);
        end
        function varargout = set(this,prop,value,idx)
            if iscell(prop)
                for i=1:2:length(prop)-1
                    this.set(prop{i},prop{i+1})
                end
            else
                try
                    if nargin == 3
                        idx = 0;
                        set(this.simBlock,prop,value);
                    else
                        set(this.simBlock,prop,sprintf('%s%d',value,idx));
                    end
                catch E
                    if strcmp(E.identifier, 'Simulink:blocks:DupBlockName')
                        % Name already exists, add number
                        this.set(prop,value,idx+1);
                    end
                end
            end
            
            if nargout == 1
                varargout{1} = this;
            end
        end
        
        % From https://it.mathworks.com/help/matlab/matlab_oop/implementing-operators-for-your-class.html
        %% Add
        function r = plus(b1,b2)
            r = binary_operator(b1,b2,'ops','Add');
        end
        function r = minus(b1,b2)
            r = binary_operator(b1,b2,'ops','Subtract');
        end
        function r = uplus(b1)
            r = b1;
        end
        function r = uminus(b1)
            % r = binary_operator(b1,-1,'ops','Product');
            r = Gain(b1,'value',-1);
        end
        
        %% Product
        function r = times(b1,b2)
            r = binary_operator(b1,b2,'ops','Product');
        end
        function r = mtimes(b1,b2)
            r = binary_operator(b1,b2,'ops','Product','Multiplication','Matrix(*)');
        end       
        
        %% Division
        function r = rdivide(b1,b2)
            r = binary_operator(b1,b2,'ops','Divide');
        end
        function r = ldivide(b1,b2)
            r = binary_operator(b2,b1,'ops','Divide','Multiplication','Matrix(*)');
        end
        function r = mrdivide(b1,b2)
            r = binary_operator(b1,b2,'ops','Divide','Multiplication','Matrix(*)');
        end
        function r = mldivide(b1,b2)
            r = binary_operator(b2,b1,'ops','Divide','Multiplication','Matrix(*)');
        end
        
        %% Math operation
        function r = power(b1,b2)
            if isnumeric(b2) && isscalar(b2) && b2==1
                r = b1;
            elseif isnumeric(b2) && isscalar(b2) && b2==2
                r = binary_operator(b1,b1,'ops','Product');
            else
                r = binary_operator(b1,b2,'ops','Math Function','Function','pow');
            end
        end
        function r = mpower(b1,b2)
            r = binary_operator(b1,b2,'ops','Math Function','Function','pow');
        end
        
        %% Compare
        function r = lt(b1,b2)
            r = binary_operator(b1,b2,'ops','Relational Operator','Operator','<');
        end
        function r = gt(b1,b2)
            r = binary_operator(b1,b2,'ops','Relational Operator','Operator','>');
        end
        function r = le(b1,b2)
            r = binary_operator(b1,b2,'ops','Relational Operator','Operator','<=');
        end
        function r = ge(b1,b2)
            r = binary_operator(b1,b2,'ops','Relational Operator','Operator','>=');
        end
        function r = ne(b1,b2)
            r = binary_operator(b1,b2,'Relational Operator','Operator','~=');
        end
        function r = eq(b1,b2)
            r = binary_operator(b1,b2,'ops','Relational Operator','Operator','==');
        end
        
        %% Logical
        function r = and(b1,b2)
            r = binary_operator(b1,b2,'ops','Logical Operator','Operator','AND');
        end
        function r = or(b1,b2)
            r = binary_operator(b1,b2,'ops','Logical Operator','Operator','OR');
        end
        function r = not(b1)
            r = unary_operator(b1,'ops','Logical Operator','Operator','NOT');
        end
        
        %% Vector
        function r = concat(varargin)
            r = [];
            for v = 1:length(varargin)
                if isempty(r)
                    r = varargin{v};
                else
                    r(end+1:end+length(varargin{v})) = varargin{v};
                end
            end
        end
        function r = horzcat(varargin)
            r = Mux(varargin);
        end
        function r = vertcat(varargin)
            r = Mux(varargin);
        end
        
        %% Subscript
        function varargout = subsref(A,S)
            if length(S) == 1
                switch S(1).type
                    case '()'
                        if length(S(1).subs) == 1 && length(S(1).subs{1}) == 1 && S(1).subs{1} < 0
                            dl = abs(S(1).subs{1});
                            varargout{1} = Delay(A,'DelayLength',dl);
                            return
                        end
                    otherwise
                end
            end
            [varargout{1:nargout}] = builtin('subsref',A,S);
        end
    end
end

