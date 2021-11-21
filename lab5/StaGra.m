function [Yg,Xg] = StaGra(Y,X)
    a=size(Y);
    a=a(2);
    Yg=[];
    Xg=[];
    l=1/9;
    Pr=0;
    for i=1:a
        Yg=[Yg double(vpa(Y(i)))];
        Pr=Pr+l;
    end
    k=size(Yg);
    Xg=[0:X/(k(2)-1):X];
end

