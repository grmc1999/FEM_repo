close all
clear all
%%
%%Parametros iniciales
syms s(x)
%syms L H de
L=1.5;%[m]
H=1;%[m]
de=8*10^(-3)/(10^(-2))^3*9.81;%densidad especifica
deppp=de;
d=0.12;%[m]
p=0;
E=2*10^5/(10^(-3))^2;%[N/m]
P1=30000;%[N]
alpha=11*10^(-6);%[1/C]
%%
%%definición de la superficie
s(x)=-(2*L/H)*abs(x)+L
xi=-H/2:0.1:H/2;
yi=s(xi);
plot(xi,yi)
hold on
%%
%distribución de temperatura
syms T(x)
dT=125;
%%
%hallando medidas de los elementos
%numero de elementos:
n=4;
%rangos de integracion
syms x(y)
x(y)=(-y+L)*(H/(2*L));
R=[];
nd=[];
Hi=[];
for i=1:n+1
    R(i)=(i-1)*L/n;
    nd(i)=i;
end
for i=0:n-1
    yp=2*(int(x,y,R(i+1),R(i+2)));
    Hi(i+1)=yp/(L/n);
end
a=size(xi);
%graficar elementos
for i=1:n
    plot([-Hi(i)/2,Hi(i)/2],[R(i)+L/n,R(i)+L/n])
    hold on
    plot([-Hi(i)/2,-Hi(i)/2],[R(i),R(i)+L/n])
    hold on
    plot([Hi(i)/2,Hi(i)/2],[R(i),R(i)+L/n])
    hold on
end
%%
%tabla de conectividad
GDLG=1;%grados de libertad globales
for i=1:n
    fprintf('[(%i)|%i %i|%i %i]\n',i,nd(i),nd(i+1),nd(i),nd(i+1))%elemento|nodos|GDL(fuerzas)
end
%%
%vector de fuerzas
P=zeros(1,n+1);
P((n+2)/2)=-P1;
%P=[0 0 P1 0 0];
Fd=[];
Fm=[];
Th=[];
%Fuerzas distribuidas
Fd(1)=(p*L/n)/2;
for i=2:n
    Fd(i)=(p*L/n);
end
Fd(i+1)=(p*L/n)/2;
%Fuerzas masicas
Fm(1)=(de*Hi(1)*d*L/n)/2;
for i=2:n
    Fm(i)=(de*Hi(i)*d*L/n)/2+(de*Hi(i-1)*d*L/n)/2;
end
Fm(i+1)=(de*Hi(n)*d*L/n)/2;
%Fuerzas virtuales por temperatura
Th(1)=-(E*Hi(1)*d*alpha*dT);
for i=2:n
    Th(i)=(E*Hi(i-1)*d*alpha*dT)-(E*Hi(i)*d*alpha*dT);
end
Th(i+1)=(E*Hi(n)*d*alpha*dT);
%Vector de Fuerzas
F=Fd+P-Fm+Th;
%Rigidez local
B=[-1 1];
Ke=[];
K=zeros(n+1);
for i=1:n
    Ke(:,:,i)=(Hi(i)*d/(L/n))*E*B'*B;
    Kt=zeros(n+1);
    Kt(i:i+GDLG,i:i+GDLG)=Ke(:,:,i);
    K=K+Kt;
end
Q=zeros(1,n+1);
Q(2:n+1)=inv(K(2:n+1,2:n+1))*F(2:n+1)';
R1=Q*K(:,1)-F(1)
q=[];
for i=1:n
    q(:,i)=[Q(i),Q(i+1)];
end
DefT=ones(1,n)*E*alpha*dT;
Sig=E*B*q/(L/n)-DefT;
