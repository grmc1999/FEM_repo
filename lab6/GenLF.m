function LF= GenLF(l,m)
    LF=zeros(4,6);
    LF(1,1)=-m;
    LF(1,2)=l;
    LF(2,3)=1;
    LF(3,4)=-m;
    LF(3,5)=l;
    LF(4,6)=1;
end

