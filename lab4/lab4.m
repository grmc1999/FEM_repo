close all
clear all
%%
%parametros del sistema
nn=12; %numero de nodos
ne=31;%numero de elementos
h=1.2;%[m]
D=0.05;%diametro[m]
E=2.1*10^11;%[Pa]
A=pi*D^2/4;%[m^2]
Pa=12000;%[N]
Pb=8000;%[N]
R1=[1 1 1];
R2=[0 1 1];
R3=[1 1 1];
R4=[0 1 1];
%%
%Ubicación de nodos
a=0.75/(3^0.5);%[m]
b=0.5;%[m]
c=0.75;%[m]
P=[0 0 0;3*c 0 0;0 b 0;3*c b 0;...
    c 0 0;2*c 0 0;c b 0;2*c b 0;...
    c 0 -a;2*c 0 -a;...
    c b -a;2*c b -a;...
    ];
%%
%conexiones
% con=[1 5;5 6;6 2;5 7;6 8;3 7;7 8;8 4;1 7;6 7;2 8;...
%     3 9;7 9;8 10;4 10;...
%     1 9;5 9;6 9;6 10;2 10;3 11;7 11;8 11;8 12;4 12;...
%     9 10;10 12;11 12;9 11;10 11;9 8;...
%     ];
con=[1 5;5 6;6 2;5 7;6 8;3 7;7 8;8 4;1 7;6 7;2 8;...
    3 9;7 9;8 10;4 10;...
    1 9;5 9;6 9;6 10;2 10;3 11;7 11;8 11;8 12;4 12;...
    9 10;10 12;11 12;9 11;9 12;7 10;...
    ];
ConGDL=[];
for i=1:ne
    ConGDL=[ConGDL;con(i,1)*3-2 con(i,1)*3-1 con(i,1)*3 con(i,2)*3-2 con(i,2)*3-1 con(i,2)*3];
end
Le=[];
lm=[];
LM=[];
Ktw=[];
Krs=[];
BBt=[1 -1;-1 1];
%%
%areas
Ae=[A,A,A,A,A,A,A,A,A,A,A,...
    A,A,A,A,...
    A,A,A,A,A,A,A,A,A,A,...
    A,A,A,A,A,A...
    ];%longitud de cada elemento[m^2]
%%
%matriz de rigidez para cada elemento
for i=1:ne
    d=P(con(i,2),:)-P(con(i,1),:);%longitud de elemtos en coordenadas generales
    le=norm(d);%distancia de cada elemento
    Ktw=[Ktw BBt*Ae(i)*E/le];
    %valores de l y m para cada elemento
    lm=[lm;[d(1)/le d(2)/le d(3)/le]];
    Le=[Le,le];
    %Matriz de transformación a coordenadas externas
    LM=[LM [lm(i,1) lm(i,2) lm(i,3) 0 0 0;0 0 0 lm(i,1) lm(i,2) lm(i,3)]];
    Krs=[Krs (LM(:,6*i-5:6*i)')*(Ktw(:,2*i-1:2*i))*((LM(:,6*i-5:6*i)))];
end
%%
%Ensamble de matriz de rigidez global
Kij=zeros(nn*3,nn*3);
for i=1:ne
    krs=Krs(:,(6*i-5:6*i));
    aux=ConGDL(i,:);
    %puede ser generalizado con GDL
    for j=1:6
        for k=1:6
            Kij(aux(j),aux(k))=Kij(aux(j),aux(k))+krs(j,k);
        end
    end
end
%%
%Vector de fuerzas
F=zeros(nn*3,1);
F(3*1-2:3*1,1)=R1';
F(3*2-2:3*2,1)=R2';
F(3*3-2:3*3,1)=R3';
F(3*4-2:3*4,1)=R4';
F(3*9,1)=-Pa/2;
F(3*11,1)=-Pa/2;
F(3*10,1)=-Pb/2*cos(60*pi/180);
F(3*12,1)=-Pb/2*cos(60*pi/180);
F(3*10-2,1)=Pb/2*sin(60*pi/180);
F(3*12-2,1)=Pb/2*sin(60*pi/180);
Q=zeros(nn*3,1);
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
    qe=[Q(ConGDL(i,1));Q(ConGDL(i,2));Q(ConGDL(i,3));Q(ConGDL(i,4));Q(ConGDL(i,5));Q(ConGDL(i,6))];
    Sig=[Sig (E/Le(i))*lme*qe];
end
%%
%presentacion de resultados
for i=1:ne
    pii=[P(con(i,1),1),P(con(i,2),1)];
    pf=[P(con(i,1),2),P(con(i,2),2)];
    pff=[P(con(i,1),3),P(con(i,2),3)];
    plot3(pii,pf,pff,'k')
    hold on
end
Pf=[];
sc=1285.2003096036126;
for i=1:nn
    Pf(i,1)=P(i,1)+Q(3*i-2)*sc;
    Pf(i,2)=P(i,2)+Q(3*i-1)*sc;
    Pf(i,3)=P(i,3)+Q(3*i)*sc;
end
for i=1:ne
%     pii=[Pf(con(i,1),1),Pf(con(i,2),1)];
%     pf=[Pf(con(i,1),2),Pf(con(i,2),2)];
%     pff=[Pf(con(i,1),3),Pf(con(i,2),3)];
%     plot3(pii,pf,pff,'r')
    hold on
end