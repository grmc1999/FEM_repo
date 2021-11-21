function [Yg,Xg] = StaGra(Y,X)
    a=size(Y);
    a=a(2);
    Yg=[];
    Xg=[];
    l=1/9;
    Pr=0;
    for i=1:a
        Yg=[Yg double(vpa(Y(i)))];
        Xg=[Xg Pr:l/(a-1):Pr+l];
        Pr=Pr+l;
    end
end

