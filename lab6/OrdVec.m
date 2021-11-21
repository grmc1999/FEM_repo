function V=OrdVec(V,val1,val2)
    temp=V(val1);
    V(val1)=V(val2);
    V(val2)=temp;
end