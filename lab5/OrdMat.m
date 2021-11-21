function M=OrdMat(M,val1,val2)
    aux=M(val1,:);
    M(val1,:)=M(val2,:);
    M(val2,:)=aux;
    aux=M(:,val1);
    M(:,val1)=M(:,val2);
    M(:,val2)=aux;
end