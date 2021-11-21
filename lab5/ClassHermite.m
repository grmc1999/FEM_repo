classdef ClassHermite
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        var
        VecG=[]
        H=[]
        pts=[]
        n
        Mat=[]
    end
    
    methods

        function obj=Dat(obj,n)
            syms e
            obj.var=e;
            obj.n=n;
            obj=GenP(obj);
            obj=GenVecG(obj);
            obj=GenMat(obj);
             obj=GenFunL(obj);
        end
        
        function obj=GenP(obj)
            obj.pts=[];
            for i=0:obj.n-1
                obj.pts=[obj.pts,-1+(2/(obj.n-1))*(i)];
            end
        end
        
        function obj=GenVecG(obj)
            for i=1:obj.n
                obj.VecG=[obj.VecG obj.var^(2*i-2) obj.var^(2*i-1)];
            end            
        end
        
        function obj=GenMat(obj)
            F(obj.var)=obj.VecG;
            Fp=diff(F);
            for i=1:obj.n
                obj.Mat=[obj.Mat;F(obj.pts(i));Fp(obj.pts(i))];
            end
        end
        
        function obj=GenFunL(obj)
            obj.H=[];
            for i=1:obj.n
                h1=(obj.VecG)*(((obj.Mat)^(-1))*(Ys(2*obj.n,2*i-1)));
                h2=(obj.VecG)*(((obj.Mat)^(-1))*(Ys(2*obj.n,2*i)));
                obj.H=[obj.H h1 h2];
            end
        end
        
        function ev=FL(obj,x)
            ev=obj.H(x)
        end
    end  
end
