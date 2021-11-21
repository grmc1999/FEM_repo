close all
clear all
%%
%parametros del sistema
Ne=2;%cantidad de nodos por elemento
N=3;%numero de nodos
nn=N+(N-1)*(Ne-2); %numero de nodos
ne=nn-1;%numero de elementos
GDL=2;%grados de libertad por nodo
h=1;%[m]
syms e;
syms y;
%Información sobre la sección
A=0.1*0.02+0.02*0.08;%[m²]
alp=3.0994;
OrM=2*GDL;

E=2*10^11;%[Pa]
NR=4;%Numero de reacciones
I=4*10^(-6);
%0->no hay reaccion
%1->hay reaccion
R1=[1 0];
R2=[1 0];
%%
%Ubicación de nodos
P=[];
O=0;
P=[0 0;1 0;2 0];
%%
%conexiones
con=[];
for i=1:ne
    temp=[];
    for j=0:Ne-1
        temp=[temp i+j];
    end
    con=[con; temp];
end
ConGDL=[];
NC=size(con);
NC=NC(2);
for i=1:ne
    cont=0;
    tem=zeros(1,2*GDL);
    for j=1:Ne
       for k=1:(GDL)
           cont=cont+1;
           tem(cont)=con(i,j)*(GDL)-(GDL-k);
       end
    end
    ConGDL=[ConGDL;tem];
    
end
Le=[];
Ktw=[];
Krs=[];
%%
%areas
Ae=ones(1,ne)*A;%longitud de cada elemento[m^2]
Ie=ones(1,ne)*I;
%%
%Definición de funcion de interpolación
FunInter=ClassHermite;
FunInter=Dat(FunInter,Ne);
H=FunInter.H;
H(e)=H;
ddH(e)=diff(diff(H));

%%
%matriz de rigidez para cada elemento
for i=1:ne
    d=P(con(i,2),:)-P(con(i,1),:);%longitud de elemtos en coordenadas generales
    le=norm(d);%distancia de cada elemento
    V=VecEsc(Ne,le/2);
    ddHq(e)=ddH.*transpose(V);
    Hq(e)=H.*transpose(V);
    ktw=int((transpose(ddHq)*ddHq),-1,1);
    Ktw=[Ktw ktw*Ie(i)*E*8/(le^3)];
    Le=[Le,le];
    Krs=[Krs (Ktw(:,OrM*i-(OrM-1):OrM*i))];
end
%%
%Ensamble de matriz de rigidez global
Kij=zeros(nn*2,nn*2);
for i=1:ne
    krs=Krs(:,(OrM*i-(OrM-1):OrM*i));
    aux=ConGDL(i,:);
    for j=1:OrM
        for k=1:OrM
            Kij(aux(j),aux(k))=Kij(aux(j),aux(k))+krs(j,k);
        end
    end
end
%%
%Vector de fuerzas
%0->no hay reaccion
%1->hay reaccion
F=[1;1;1;-1000;1;1000];
%F=zeros(nn*GDL,1);
%F(2*1-1:2*1,1)=R1';
%F(round(nn*2*7/10),1)=M;
%F(nn*2-1:nn*2,1)=R2';
%%
%solución del sistema
%operaciones de filas y columnas para simplificar el calculo
cambios=[];
for i=1:nn*GDL
    if F(i)~=1
        for j=i:nn*GDL
            if F(j)==1
                cambios=[cambios;i j];
                Kij=OrdMat(Kij,j,i);
                F=OrdVec(F,j,i);
                break
            end
        end
    end
end
%Solucion del sistema
aux=sum(F(:)==1)+1;
subKij=Kij((aux:nn*GDL),(aux:nn*GDL));
Q((aux):nn*GDL)=subKij\(F((aux):nn*GDL));
%Reacciones
R=Kij*transpose(Q)-F;
F=F+R;
n=size(cambios);
n=n(1);
for i=1:n
    Kij=OrdMat(Kij,cambios(n+1-i,1),cambios(n+1-i,2));
    F=OrdVec(F,cambios(n+1-i,1),cambios(n+1-i,2));
    Q=OrdVec(Q,cambios(n+1-i,1),cambios(n+1-i,2));
end
%%
%calculo de esfuerzos
Sig=[];
Tau=[];
v=[];
dddHq=diff(ddHq);
for i=1:ne
    qe=[];
    for j=1:GDL*Ne
        qe=[qe;Q(ConGDL(i,j))];
    end
    v=[v Hq*qe];
    fnn(e,y)=-4*(E*y/(Le(i)^2))*ddHq(e)*qe;
    Sig=[Sig fnn];
    Tau=[Tau 8*(alp*E*Ie(i)/(Ae(i)*Le(i)^3))*dddHq*qe];
end
Mf=-I*Sig(e,1);
Mf(e)=Mf;
V=A*Tau/alp;
V(e)=V;
%EE=[-1:2/(ne-1):1];
EE=2;
EEl=[-1 1];
YYl=[-32.2/1000 67.8/1000];
%Esfuerzos maximos
EsMax=MaxL(Sig,EEl,YYl);
DesMax=max(abs(double(vpa(vg))));
%%
%presentacion de resultados
%Deformada
vg=v(EE);
[vgg,Eg]=StaGra(vg,EE);
figure(1)
%Eg=[0:2/41:2]
%plot(Eg,vgg);
%xlabel('Logitud [m]')
%ylabel('Despazamiento vertical [m]')
%ylim([-0.00005 0.00005])
%grid on

%Momento flector
Mfg=Mf(EE);
[Mfgg,Eg]=StaGra(Mfg,EE);
figure(2)
plot(Eg,Mfgg);
xlabel('Logitud [m]')
ylabel('Momento Flector [N-m]')
grid on

%Esfuerzo Cortante
Vg=V(EE);
[Vgg,Eg]=StaGra(Vg,EE);
figure(3)
Eg=[Eg 1];
Vgg=[Vgg 0];
plot(Eg,Vgg);
xlabel('Logitud [m]')
ylabel('Cortante [N]')
ylim([0 300])
grid on

%Esfuerzos maximos
EsMax=MaxL(Sig,EEl,YYl);
DesMax=max(abs(double(vpa(vg))));

