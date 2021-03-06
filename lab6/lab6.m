close all
clear all
%%
%parametros del sistema
Ne=2;%cantidad de nodos por elemento
N=4;%numero de nodos
nn=N+(N-1)*(Ne-2); %numero de nodos
ne=3;%numero de elementos
GDL=3;%grados de libertad por nodo
h=1.2;%[m]
D=0.05;%diametro[m]
E=30*10^6;%[Pa]
%A=pi*D^2/4;%[m^2]
A=6.;
alp=4/3;
syms e;
syms y;
OrM=2*GDL;

NR=6;%Numero de reacciones
%I=0.25*pi*(D/2)^4;
I=65;
%0->no hay reaccion
%1->hay reaccion
%%
%Ubicación de nodos
%P=[-2*h 0;-h 0;0 0;-h -h;0 -h];
P=[0 8;12 8;0 0;12 0];
%%
%conexiones
con=[];
%con=[1 2;2 3;1 4;2 4;3 4;3 5;4 5];
con=[1 2;1 3;2 4];
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
FunInterFlex=ClassHermite;
FunInterFlex=Dat(FunInterFlex,Ne);
Hf=FunInterFlex.H;
Hf(e)=Hf;
ddHf(e)=diff(diff(Hf));
dddHf(e)=diff(ddHf);

FunInterTrac=ClassLagrange;
FunInterTrac=Dat(FunInterTrac,Ne);
Hl=FunInterTrac.H;
Hl(e)=Hl;
dHl(e)=diff(Hl);

%%
%matriz de rigidez para cada elemento
lm=[];
LM=[];
for i=1:ne
    d=P(con(i,2),:)-P(con(i,1),:);%longitud de elemtos en coordenadas generales
    le=norm(d);%distancia de cada elemento
    
    V=VecEsc(Ne,le/2);
    ddHfq(e)=ddHf.*transpose(V);
    Hfq(e)=Hf.*transpose(V);
    ktwf=int((transpose(ddHfq)*ddHfq),-1,1);
    ktwf=ktwf*Ie(i)*E*8/(le^3);
    
    dHlq(e)=dHl*2/le;
    Hlq(e)=Hl*2/le;
    ktwl=2*int((transpose(dHl)*dHl),-1,1);
    ktwl=ktwl*Ae(i)*E/(le);
    
    ktw=EnsKTW(ktwl,ktwf);
    
    
    Ktw=[Ktw ktw];
    lm=[lm;[d(1)/le d(2)/le]];
    ltr=GenLtr(d(1)/le,d(2)/le);
    LM=[LM ltr];
    Le=[Le,le];
    Krs=[Krs ltr'*(Ktw(:,OrM*i-(OrM-1):OrM*i))*ltr];
end
%%
%Ensamble de matriz de rigidez global
Kij=zeros(nn*GDL,nn*GDL);
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
F=[3000;-3000;-6000;0;-3000;6000;1;1;1;1;1;1];
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
F
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
Sigf=[];
Sigt=[];
Tau=[];
v=[];
dddHfq=diff(ddHfq);
for i=1:ne
    qe=[];
    for j=1:GDL*Ne
        qe=[qe;Q(ConGDL(i,j))];
        LF=GenLF(lm(i,1),lm(i,2));
        LT=GenLT(lm(i,1),lm(i,2));
    end
    v=[v Hf*LF*qe];
    fnn(e,y)=-4*(E*y/(Le(i)^2))*ddHf(e)*LF*qe;
    Sigf=[Sigf fnn];
    Tau=[Tau 8*(alp*E*Ie(i)/(Ae(i)*Le(i)^3))*dddHf*LF*qe];
    
    Sigt=[Sigt (E/Le(i))*2*dHl*LT*qe];
end
Mf=-I*Sigf(e,1);
Mf(e)=Mf;
V=A*Tau/alp;
V(e)=V;
EE=[-1:2/(ne-1):1];
EEl=[-1:2/10:1];
YYl=[-0.025:0.05/10:0.025];
Sig(e,y)=Sigf+Sigt(e);
%%
%Esfuerzos maximos
EsMaxf=MaxL(Sigf,EEl,YYl);
EsMaxt=MaxL(Sig,EEl,YYl);

%%
%informacion para el informe
Sigtt=double(vpa(Sigt));
Tau=double(vpa(Tau));
nue=[1:1:ne];
TC=[nue' con lm ConGDL EsMaxf EsMaxt Sigtt' Tau'];
TN=[F Q'];
