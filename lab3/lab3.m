close all
clear all
%%
%parametros del sistema
GDL=2;
nn=3; %numero de nodos
D=0.05;%diametro[m]
E=2*10^11;%[Pa]
A=645.16*10^(-6);%[m^2]
Pa=5400;%[N]
Pb=4000;%[N]
Pc=2500;%[N]
Pe=3000;%[N]
%0->no hay reaccion
%1->hay reaccion
R1=[1 1];
R2=[1 1];
R3=[1 1];
R4=[0 1];
%%
%Ubicación de nodos
%P=[-2*h 0;-h 0;0 0;-h -h;0 -h];
P=[0 0;1 0;0 2];
%%
%conexiones
%con=[1 2;2 3;1 4;2 4;3 4;3 5;4 5];
con=[1 2;2 3;1 3];
ConGDL=[];
ne=size(P);
ne=ne(1);
for i=1:ne
    ConGDL=[ConGDL;con(i,1)*2-1 con(i,1)*2 con(i,2)*2-1 con(i,2)*2];
end
Le=[];
lm=[];
LM=[];
Ktw=[];
Krs=[];
BBt=[1 -1;-1 1];
%%
%areas
Ae=[A,A,A,A];%longitud de cada elemento[m]
%%
%matriz de rigidez para cada elemento
for i=1:ne
    d=P(con(i,2),:)-P(con(i,1),:);%longitud de elemtos en coordenadas generales
    le=norm(d);%distancia de cada elemento
    Ktw=[Ktw BBt*Ae(i)*E/le];
    %valores de l y m para cada elemento
    lm=[lm;[d(1)/le d(2)/le]];
    Le=[Le,le];
    %Matriz de transformación a coordenadas externas
    LM=[LM [lm(i,1) lm(i,2) 0 0;0 0 lm(i,1) lm(i,2)]];
    Krs=[Krs (LM(:,4*i-3:4*i)')*(Ktw(:,2*i-1:2*i))*((LM(:,4*i-3:4*i)))];
end
%%
%Ensamble de matriz de rigidez global
Kij=zeros(nn*2,nn*2);
for i=1:ne
    krs=Krs(:,(4*i-3:4*i));
    aux=ConGDL(i,:);
    %puede ser generalizado con GDL
    for j=1:4
        for k=1:4
            Kij(aux(j),aux(k))=Kij(aux(j),aux(k))+krs(j,k);
        end
    end
end
%%
%Vector de fuerzas
%0->no hay reaccion
%1->hay reaccion
%F=[-7.8667;-5.9;0;-9.833;7.8667;15.733;0;0]*1000;
F=[1;1;14341.3;1;5638.4;18772.9];
Q=zeros(nn*2,1);
%%
%solución del sistema
%operaciones de filas y columnas para simplificar el calculo
cambios=[];
cont=0;
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
R=Kij*Q-F;
F=F+R;
n=size(cambios);
n=n(1);
for i=1:n
    Kij=OrdMat(Kij,cambios(n+1-i,1),cambios(n+1-i,2));
    F=OrdVec(F,cambios(n+1-i,1),cambios(n+1-i,2));
    Q=OrdVec(Q,cambios(n+1-i,1),cambios(n+1-i,2));
end
%calculo de esfuerzos
Sig=[];
for i=1:ne
    lme=[-lm(i,:) lm(i,:)];
    qe=[Q(ConGDL(i,1));Q(ConGDL(i,2));Q(ConGDL(i,3));Q(ConGDL(i,4))];
    Sig=[Sig (E/Le(i))*lme*qe];
end
Sig
%%
%presentacion de resultados
for i=1:ne
    pi=[P(con(i,1),1),P(con(i,2),1)];
    pf=[P(con(i,1),2),P(con(i,2),2)];
    plot(pi,pf,'k')
    hold on
end
Pf=[];
for i=1:nn
    Pf(i,1)=P(i,1)+Q(2*i-1)*1095.1115756297886;
    Pf(i,2)=P(i,2)+Q(2*i)*1095.1115756297886;
end
for i=1:ne
    pi=[Pf(con(i,1),1),Pf(con(i,2),1)];
    pf=[Pf(con(i,1),2),Pf(con(i,2),2)];
    plot(pi,pf,'r')
    hold on
end