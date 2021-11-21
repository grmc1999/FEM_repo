classdef ClassLagrange
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        var
        coef=[]
        H=[]
        pts=[]
        n
    end
    
    methods

        function obj=Dat(obj,n)
            syms e
            obj.var=e;
            obj.n=n;
            obj=GenP(obj);
            obj=GenFunL(obj);
        end
        
        function obj=GenP(obj)
            obj.pts=[];
            for i=0:obj.n-1
                obj.pts=[obj.pts,-1+(2/(obj.n-1))*(i)];
            end
        end
        
        function obj=GenFunL(obj)
            obj.H=[];
            for i=1:obj.n
                den=(obj.pts(i)-obj.pts);
                den(i)=1;
                den=mulVal(den);
                num=(obj.var-obj.pts);
                num(i)=1;
                num=mulVal(num);
                H(obj.var)=(num/den);
                obj.H=[obj.H,H];
            end
        end
        
        function ev=FL(obj,x)
            ev=obj.H(x)
        end
    end  
end

