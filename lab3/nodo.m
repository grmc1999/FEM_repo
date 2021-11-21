classdef nodo < handle
    properties
        GDL=[]
        Enlaces
        i
    end
    methods
        function r = imp(obj)
            r=obj;
            disp(r);
        end
        function self = nodo(varargin)
            if nargin>0
                self.GDL=ones(1,varargin{1});
                self.i=varargin{2};
            end
        end
    end
end