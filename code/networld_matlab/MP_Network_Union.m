
function [T, Union_Allow, Fin_Union] = MP_Network_Union(A, B)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MP_Network_Union: 
%   Joins two networks A, B according to the criterion of gaining centrality (>)
%   So that the centrality of the larger is 1 and that of the smaller is 0,
%   the union is done first by blocks, the first block being the largest and the
%   second being the smallest.

% Inputs:
%   A, B: Adjacency matrices of the networks.
% Outputs:
%    T: Adjacency matrix of the final network.
%    Union_Allow: 0 if they have not joined and 1 if they have joined.
%    Fin_Union: 0 if the union has been solved approximately and 0
%    otherwise

% To understand better how this programm work, see Sup. Information in ...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initial variables
[na,~] = size(A);
[nb,~] = size(B);

T_Counter = (na+nb)^3;  %Counter of the maximum succesfull links allowed


%% We join the networks for the first time
%%M%% blkdiag expande la matriz de la forma [A,0;0,B], con las matrices
%%individuales en la diagonal y el resto relleno a 0 (porque aun no hay
%%conexiones entre ambas)
if na < nb
    A1 = B;
    A2 = A;
    T = blkdiag(A1, A2); %Union by blocks of networks
else
    A1 = A;
    A2 = B;
    T = blkdiag(A1,A2);
end

%% We generate the list of links and we permute it.
[na,~] = size(A1);
[nb,~] = size(A2);

%%M%% Una serie de operaciones para acabar con la lista de posibles enlaces
%%permutada y en formato [2,nº posibilidades]
L1 = 1:1:na;
L2 = 1:1:nb;
[L1,L2] = ndgrid(L1,L2);
Lista = [L1(:),L2(:)];
Lista = Lista';
[~,Len_Lista] = size(Lista);


%% Main Loop
%Stop Flags
%%M%%
    % Flag_List = 1 -> se han comprobado y rechazado todos los enlaces
    % posibles en un punto dado del proceso
    % Flag_Counter = 1 -> se han hecho el numero maximo de pasos
    % Flag_Loop = 1 -> se ha encontrado un bucle en la reorganizacion de
    % conexiones
    % Flag_Rand: flag que utiliza para cambiar entre seguir la lista y
    % sacar un enlace al azar, pero realmente es lo mismo que si solo
    % siguiera con la lista porque cada vez que acepta un enlace la permuta
    % y el enlace que muestrearía sería aleatorio
Flag_List = 0;
Flag_Counter = 0;
Flag_Loop = 0;
Flag_Rand = 1;
Loop_Stop = 0;

%Variables
Counter = 0;
R = [];  % Matrix with centralities


while  Flag_List == 0 && Flag_Counter == 0 && Flag_Loop == 0
   
    %%M%% genera un enlace aleatorio al principio y cada vez que ha
    %%encontrado una conexion exitosa, pero deberia ser equivalente a
    %%seguir con una nueva permutación de la lista que hace a continuación
    if Flag_Rand == 1  % We launch links first
        for i = 1:2
            x = randi(na);
            y = randi(nb);
            [T,Flag_Loop,M,R,Loop_Stop]=MP_Try_Links(na,nb,T,x,y,R,Loop_Stop,Counter);
            Counter = Counter + M;
            % Can end by loop
            if Flag_Loop == 1
                Fin_Union = 3;
                break
            end

            % Can end by counter
            if Counter > T_Counter
                Flag_Counter = 1;
                Fin_Union = 2;
                break
            end
        end
        Flag_Rand = 0;

    elseif Flag_Rand == 0
        % Reorder the list
        x1 = randperm(Len_Lista);
        Lista(1,:) = Lista(1,x1);
        Lista(2,:) = Lista(2,x1);
        % We follow the list
        for i = 1:Len_Lista
            x = Lista(1,i);
            y = Lista(2,i);
            [T,Flag_Loop,M,R,Loop_Stop]=MP_Try_Links(na,nb,T,x,y,R,Loop_Stop,Counter);
            Counter = Counter +M;
            % If there is a loop, stop
            if Flag_Loop == 1
                Fin_Union = 3;
                break
            end

            if Counter > T_Counter
                Flag_Counter = 1;
                Fin_Union = 2;
                break
            end

            % If there is a success, we have to continue choosing at random
            if M ==1
                Flag_Rand = 1;
                break
            end

            %%If the list ends, set the end flag to 1
            if i == Len_Lista
                Flag_List = 1;
                Fin_Union = 1;
            end
        end
    end
end

%% Comprogamos que las redes se han unido
if isequal(T,blkdiag(A1, A2)) == 1
    Union_Allow = 0;
else
    Union_Allow = 1;
end
end

