classdef prueba
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        sim
        a=[1,2,3]
        b='propiedad'
        c='var'
        
    end
    
    methods
        function obj=soloimp(obj,c)
            syms e
            disp(obj.b)
            obj.c=c;
            obj.sim=e;
        end
        function a=wdf(c)
            disp('funcion en clase')
            a=c;
        end
        function  Cons(obj)
            disp('inconst')
            soloimp(obj,'a ver')
            obj.b=wdf('v');
        end
    end
    
end

