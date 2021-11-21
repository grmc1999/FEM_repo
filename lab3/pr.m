classdef pr<handle
    properties (Access=public)
        a
        b
        c
    end
    methods (Access=public)
        function self = pr(in1)
            disp(nargin)
            if nargin>0
                self.a=in1
            end
        end
        function dos = Ej2(obj,in2)
            if nargin>0
                disp(in2)
            end
        end
    end  
end