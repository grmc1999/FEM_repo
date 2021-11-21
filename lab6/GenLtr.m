function Ltr = GenLtr( l,m )
    Ltr=eye(6,6);
    Ltr(1,1)=l;
    Ltr(2,2)=l;
    Ltr(1,2)=m;
    Ltr(1,2)=-m;
    Ltr(4:5,4:5)=Ltr(1:2,1:2);
end

