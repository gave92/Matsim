classdef block < handle
%BLOCK Creates any simulink block.
% Syntax:
%   blk = block('model',MODEL,'type',TYPE);
%     MODEL is the name of the library containing the desired block.
%     TYPE is the name ("BlockName") of the block to be created.
%   blk = block('model',MODEL,'type',TYPE,ARGS);
%     ARGS is an optional list of parameter/value pairs specifying simulink
%     block properties.
%
% block Methods:
%    setInputs - set all block inputs
%    setInput - set a specific block inport input
%    outport - "selects" a block outport or sets its name
% 
% Example:
%   blk = block('model','simulink','type','Gain','ShowName','off','ForegroundColor','red');
    
    properties (Access = private)
        % Handle to simulink block
        simBlock
        % Handles to input blocks
        simInputs
        % Handle to output port
        simSelectedOutport
    end
    
    methods (Access = public)
        function this = block(varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addParamValue(p,'type','',@ischar);
            addParamValue(p,'model','simulink',@ischar);
            addParamValue(p,'copy',false,@islogical);
            addParamValue(p,'parent','',@(x) ischar(x) || ishandle(x) || isa(x,'matsim.library.block') || isa(x,'matsim.library.simulation'));
            parse(p,varargin{:})
            
            type = p.Results.type;
            model = p.Results.model;
            copy = p.Results.copy;
            strParent = matsim.helpers.getBlockPath(p.Results.parent);
            args = matsim.helpers.validateArgs(p.Unmatched);

            if isempty(strParent)
                strParent = gcs;
            end
            
            if any(strcmp(args,'name'))
                % Find existing block
                name = p.Unmatched.name;
                match = matsim.helpers.findBlock(strParent,'BlockName',name,'SearchDepth',1);
                if ~isempty(match)                    
                    this.simBlock = get_param(match{1},'handle');
                    blk = this.getUserData('block');
                    if ~isempty(blk)
                        % Block was a MATSIM block, reuse
                        this.simBlock = blk.handle;
                        this.simInputs = blk.inputs;
                        this.simSelectedOutport = blk.simSelectedOutport;
                        if ~copy
                            this.setUserData('block',{});
                            this.setUserData('block',this);
                            % this = blk;
                        end
                        this.setUserData('created',2)
                    else
                        % Block was a SIMULINK block
                        this.setUserData('block',this);
                        this.setUserData('created',1)
                        this.simInputs = struct('inport',{{}},'enable',{{}},'trigger',{{}});
                        this.setInputsFromBlock();
                    end
                    this.simSelectedOutport = 1;
                    return;
                end
            end
            
            % Create block
            match = matsim.helpers.findBlock(model,'BlockName',type);
            if ~isempty(match)
                this.simBlock = add_block(match{1},strjoin({strParent,type},'/'),'MakeNameUnique','on',args{:});
                this.setUserData('block',this)
                this.setUserData('created',0)
                this.simSelectedOutport = 1;
                this.simInputs = struct('inport',{{}},'enable',{{}},'trigger',{{}});
                % Set position to far right
                blockSizeRef = this.get('position');
                this.set('position',[1e4, 0, 1e4+blockSizeRef(3)-blockSizeRef(1), blockSizeRef(4)-blockSizeRef(2)])
            else
                error('Invalid block name')
            end            
        end

        function in = inputs(this)
            in = this.simInputs;
        end
        function out = outport(this,varargin)
            %OUTPORT "Selects" a block outport or sets its name.
            % Syntax:
            %   out = blk.outport(INDEX)
            %     Selects INDEX output port of the block. You can use this
            %     to specify which outport of the block to use as input for
            %     another block.
            %   blk.outport(INDEX,'name',SIGNAME)
            %     Set SIGNAME as name of the INDEX outport. Also sets the
            %     label of the outgoing line.
            % 
            % Example:
            %   blk = Demux('Outputs',[1 1]);
            %   blk.outport(1,'name','OUT1');
            %   Terminator(blk.outport(1));
            %   sc = Scope(blk.outport(2));
            
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addOptional(p,'index',[],@isnumeric);
            addParamValue(p,'name',[],@ischar);
            parse(p,varargin{:})
            
            index = p.Results.index;
            name = p.Results.name;
            if ~isempty(index)
                out = matsim.library.block('copy',true,'parent',matsim.helpers.getValidParent(this),'name',this.get('name'));
                out.simSelectedOutport = index;
            else
                index = this.simSelectedOutport;
                out = index;
            end
            if ~any(strcmp(p.UsingDefaults,'name'))
                ph = get(this,'porthandles');
                set(ph.Outport(index),'SignalNameFromLabel',name);
            end
        end
        
        function h = handle(this)
            h = this.simBlock;
        end
        function p = get(this,prop)
            p = get(this.simBlock,prop);
        end
        function [] = set(this,prop,value)
            if iscell(prop)
                arrayfun(@(i) this.set(prop{i},prop{i+1}), 1:2:length(prop)-1)
                return
            end
            
            if strcmpi(prop,'name')
                parent = matsim.helpers.getValidParent(this);
                match = matsim.helpers.findBlock(parent,'BlockName',value,'SearchDepth',1,'Exact',false);
                if isempty(match)
                    this.safe_set(prop,matsim.helpers.validateArgs(value));
                else
                    idx = 1+length(match);
                    this.safe_set(prop,sprintf('%s%d',matsim.helpers.validateArgs(value),idx));
                end                
            else
                this.safe_set(prop,matsim.helpers.validateArgs(value));
            end
        end
    end
    
    methods (Access = private)
        function [] = safe_set(this,prop,value)
            try
                set(this.simBlock,prop,value);
            catch ex
                warning(ex.message)
            end
        end
        function [] = setInputsFromBlock(this)
            ports = get(this,'porthandles');
            for i=1:length(ports.Inport)
                line = get(ports.Inport(i),'line');
                if (line == -1 || get(line,'SrcBlockHandle') == -1)
                    this.setInput(i,'value',{},'type','inport');
                else                    
                    src_block = matsim.library.block('name',get(get(line,'SrcBlockHandle'),'name'),'parent',matsim.helpers.getValidParent(this));
                    src_port = get(get(line,'SrcPortHandle'),'PortNumber');
                    this.setInput(i,'value',src_block,'srcport',src_port,'type','inport');
                end
            end
        end
    end
    
    methods (Access = protected)
        function [] = setInputs(this,varargin)
            %SETINPUTS Set all block inputs
            % Syntax:
            %   blk.setInputs(INPUTS)
            %     INPUTS blocks will be connected to the block input ports.
            %     INPUTS can be:
            %       - an empty cell {}
            %       - a matsim block
            %       - a number
            %       - a cell array of the above
            %     If INPUTS is a number a Constant block with that value will
            %     be created.
            % 
            % Example:
            %   in1 = FromWorkspace('var1');
            %   in2 = Constant('var2');
            %   blk = block('model','simulink','type','Mux','Inputs','4');
            %   blk.setInputs({in1,{},0,in2})
            
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;
            addRequired(p,'value');
            parse(p,varargin{:})
            
            value = p.Results.value;
            parent = matsim.helpers.getValidParent(this);
            if ~isempty(value)
                validatedInputs = matsim.helpers.validateInputs(value,parent);
                if ~iscell(validatedInputs)
                    validatedInputs = {validatedInputs};
                end
                this.simInputs.inport = validatedInputs(cellfun(@(x) strcmp(x.type,'inport'),validatedInputs));
                this.simInputs.enable = validatedInputs(cellfun(@(x) strcmp(x.type,'enable'),validatedInputs));
                this.simInputs.trigger = validatedInputs(cellfun(@(x) strcmp(x.type,'trigger'),validatedInputs));
            end
        end
        function [] = setInput(this,varargin)
            %SETINPUT Set a specific block inport input
            % Syntax:
            %   blk.setInput(INDEX,'value',VALUE,'srcport',SRCPORT,'type',TYPE)
            %     SRCPORT of block VALUE will be connected to INDEX input
            %     port of the block.
            %     VALUE can be:
            %       - an empty cell {}
            %       - a matsim block
            %       - a number
            %     If VALUE is a number a Constant block with that value will
            %     be created.
            %     TYPE is optional and can be "inport", "enable", "trigger".
            % 
            % Example:
            %   in1 = FromWorkspace('var1');
            %   blk = block('model','simulink','type','Mux','Inputs','2');
            %   blk.setInput(1,'value',in1,'srcport',1)
            
            p = inputParser;
            p.CaseSensitive = false;
            % p.PartialMatching = false;
            p.KeepUnmatched = true;            
            addRequired(p,'index',@isnumeric);
            addParamValue(p,'value',{});
            addParamValue(p,'srcport',1,@isnumeric);
            addParamValue(p,'type','inport',@ischar);
            parse(p,varargin{:})
            
            index = p.Results.index;
            srcport = p.Results.srcport;
            type = p.Results.type;
            
            if index <= length(this.simInputs.(type))
                current = this.simInputs.(type){index};
            else
                current = matsim.library.block_input({});
            end
            
            parent = matsim.helpers.getValidParent(this);
            new_input = matsim.helpers.validateInputs(p.Results.value,parent);
            current.value = new_input.value;
            current.srcport = srcport;
            current.type = type;

            this.simInputs.(type){index} = current;
        end
        
        function setMaskParam(this,name,value)
            mname = get(this.simBlock,'MaskNames');
            mvalue = get(this.simBlock,'MaskValues');
            if isnumeric(value)
                mvalue{find(strcmp(mname,name),1)} = mat2str(value);
            elseif ischar(value)
                mvalue{find(strcmp(mname,name),1)} = value;
            end
            set(this.simBlock,'MaskValues',mvalue)
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
    end
    
    methods (Access = public)
        % From https://it.mathworks.com/help/matlab/matlab_oop/implementing-operators-for-your-class.html
        %% Add
        function r = plus(b1,b2)
            r = matsim.library.binary_operator(b1,b2,'ops','Add');
        end
        function r = minus(b1,b2)
            r = matsim.library.binary_operator(b1,b2,'ops','Subtract');
        end
        function r = uplus(b1)
            r = b1;
        end
        function r = uminus(b1)
            % r = matsim.library.binary_operator(b1,-1,'ops','Product');
            r = Gain(b1,'value',-1);
        end
        
        %% Product
        function r = times(b1,b2)
            r = matsim.library.binary_operator(b1,b2,'ops','Product');
        end
        function r = mtimes(b1,b2)
            r = matsim.library.binary_operator(b1,b2,'ops','Product','Multiplication','Matrix(*)');
        end       
        
        %% Division
        function r = rdivide(b1,b2)
            r = matsim.library.binary_operator(b1,b2,'ops','Divide');
        end
        function r = ldivide(b1,b2)
            r = matsim.library.binary_operator(b2,b1,'ops','Divide','Multiplication','Matrix(*)');
        end
        function r = mrdivide(b1,b2)
            r = matsim.library.binary_operator(b1,b2,'ops','Divide','Multiplication','Matrix(*)');
        end
        function r = mldivide(b1,b2)
            r = matsim.library.binary_operator(b2,b1,'ops','Divide','Multiplication','Matrix(*)');
        end
        
        %% Math operation
        function r = power(b1,b2)
            if isnumeric(b2) && isscalar(b2) && b2==1
                r = b1;
            elseif isnumeric(b2) && isscalar(b2) && b2==2
                r = matsim.library.binary_operator(b1,b1,'ops','Product');
            else
                r = matsim.library.binary_operator(b1,b2,'ops','Math Function','Function','pow');
            end
        end
        function r = mpower(b1,b2)
            r = matsim.library.binary_operator(b1,b2,'ops','Math Function','Function','pow');
        end
        
        %% Compare
        function r = lt(b1,b2)
            r = matsim.library.binary_operator(b1,b2,'ops','Relational Operator','Operator','<');
        end
        function r = gt(b1,b2)
            r = matsim.library.binary_operator(b1,b2,'ops','Relational Operator','Operator','>');
        end
        function r = le(b1,b2)
            r = matsim.library.binary_operator(b1,b2,'ops','Relational Operator','Operator','<=');
        end
        function r = ge(b1,b2)
            r = matsim.library.binary_operator(b1,b2,'ops','Relational Operator','Operator','>=');
        end
        function r = ne(b1,b2)
            r = matsim.library.binary_operator(b1,b2,'Relational Operator','Operator','~=');
        end
        function r = eq(b1,b2)
            r = matsim.library.binary_operator(b1,b2,'ops','Relational Operator','Operator','==');
        end
        
        %% Logical
        function r = and(b1,b2)
            r = matsim.library.binary_operator(b1,b2,'ops','Logical Operator','Operator','AND');
        end
        function r = or(b1,b2)
            r = matsim.library.binary_operator(b1,b2,'ops','Logical Operator','Operator','OR');
        end
        function r = not(b1)
            r = matsim.library.unary_operator(b1,'ops','Logical Operator','Operator','NOT');
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
            r = matsim.library.Mux(varargin);
        end
        function r = vertcat(varargin)
            r = matsim.library.Mux(varargin);
        end
        
        %% Subscript
        function varargout = subsref(A,S)
            if length(S) == 1
                switch S(1).type
                    case '()'
                        if length(S(1).subs) == 1 && length(S(1).subs{1}) == 1 && S(1).subs{1} < 0
                            dl = abs(S(1).subs{1});
                            varargout{1} = matsim.library.Delay(A,'DelayLength',dl);
                            return
                        end
                    otherwise
                end
            end
            [varargout{1:nargout}] = builtin('subsref',A,S);
        end
    end
end

