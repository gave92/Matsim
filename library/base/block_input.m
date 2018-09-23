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
            addRequired(p,'value',@(x) isempty(x) || isa(x,'block'));
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

