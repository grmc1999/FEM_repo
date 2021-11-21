function Ens= EnsKTW(ktwl,ktwf)
    Ens=zeros(6,6);
    Ens(1,1)=ktwl(1,1);
    Ens(1,4)=ktwl(1,2);
    Ens(4,1)=ktwl(2,1);
    Ens(4,4)=ktwl(2,2);
    Ens(2:3,2:3)=ktwf(1:2,1:2);
    Ens(2:3,5:6)=ktwf(3:4,1:2);
    Ens(5:6,2:3)=ktwf(1:2,3:4);
    Ens(5:6,5:6)=ktwf(3:4,3:4);
end

