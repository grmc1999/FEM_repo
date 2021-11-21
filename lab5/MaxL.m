function R = MaxL(F,Lx,Ly)
    R=[];
    [Lxg,Lyg]=meshgrid(Lx,Ly);
    Fe=F(Lxg,Lyg);
    n=size(Fe);
    n=n(2);
    for i=1:n
        Fei=double(vpa(Fe(i)));
        [y, ix]=max(max(abs(Fei)));
        [y, iy]=max(max(transpose(abs(Fei))));
        R=[R; Lx(ix) Ly(iy) Fei(iy,ix)];
    end
end

