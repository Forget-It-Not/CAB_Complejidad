
function [T,Flag_Loop,M,R,Loop_Stop]=Try_Links(na,nb,T,x,y,R,Loop_Stop,Counter)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Try_lins: Programm that tries to put a link in the process of union
% between 2 networks A and B.

% Input:
%   na, nb: Size of networks A and B
%   T: Current Union of A and B
%   x: Node from network A to link with y
%   y: Node from network B to link with x
%   R: Matrix with the centralities of the nodes of R (used to see if
%   there is a loop)
%   Loop_Stop: After a loop has been detected, the Loop_Stop would be
%   counter + r(r coming from a poisson distribution)
%   Counter: Keeps track of the successes in the addition of links

% Output:
%   T: New union of A and B
%   Flag_Loop: If Loop_Stop == Counter, the union must end and Flag_Loop=1
%   M: 1 if the link was added, 0 other wise
%   R: Updated matrix of centralities
%   Loop_Stop: New update of the Loop_Stop

% To see more information about this programm, see Sup. Information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%M%% Centralidad para cada nodo
W = zeros(1,na+nb);
Flag_Loop = 0; 
Min_Cent_Profit = 1e-6; %Min profit in centrality to accept the link

%% We have to check if the node x or y are already connected with any other node 

% T1 va a ser la matriz cambiada y T con los nodos sin cambiar de pos.
% Es decir, T1 es la nueva y T la antigua.
T1 = T;
%%M%% max(...) detecta si hay algun 1, es decir, si hay alguna conexion
%%entre x y los nodos de la otra red (que van de na : na+nb)
if max(T(x, na+1:na+nb)) == 1  % If it is 1, node x of network A is connected to network B
    %%M%% Saca el nodo de la otra red en cuestion y borra el enlace
    nx = find(T(x, na+1:na+nb));
    T1(x, na + nx) = 0;
    T1(nx+na, x ) = 0;
end
%%M%% Idem para el caso de nb conectado a la primera red
if max(T(na + y, 1:na)) == 1  %If it is 1, node y of network B is connected to network A
    ny = find(T(na +y, 1:na));
    T1(na + y, ny) = 0;
    T1(ny, na + y ) = 0;
end

%Unimos las redes por el Nodo
T1(x, na + y) = 1;
T1(na + y, x) = 1;

% We check whether centrality has improved
%%M%% Aqui va a haber bastante redundancia de recalcular la centralidad si
%%la matriz T de entrada es la misma muchas veces, se le podría dar una
%%vuelta
[u_T, lambda_T] = Autov(T);
[u_T1, lambda_T1] = Autov(T1);
%%M%% Centralidades para cada nodo y con min(_,_) > está comprobando que
%%sean ambos mayor que el umbral
cx_T  = Centrality(u_T,lambda_T, x);
cy_T  = Centrality(u_T,lambda_T, na+y);
cx_T1 = Centrality(u_T1,lambda_T1, x);
cy_T1 = Centrality(u_T1,lambda_T1, na +y);
Improve = min(cx_T1-cx_T, cy_T1-cy_T);

if Improve > Min_Cent_Profit %Union Condition
    %% Success
    T = T1;
    M = 1; % The link has been added
    %% We update the Matrix of centralities R
    for j = 1:na+nb
        C = Centrality(u_T1,lambda_T1, j);
        W(j) = C;
    end
    W = sort(W);
    % Guarda la centralidad en la matriz historica R para analizar los
    % posibles bucles
    R = vertcat(R,W);
    %% We see if there are loops
    if Loop_Stop == 0
        Long_Loop = Loop_Detector(R); %R(end-100:end,:)
        if Long_Loop ~= 0  %We update the loop stop with a Poisson distribution
            r = poissrnd(5);
            Loop_Stop = r+Counter;
        end

    elseif Counter == Loop_Stop % If True, the union must end and Flag_Loop=1
        Flag_Loop = 1;
    end

else
    M = 0; % The link has not been added
end
end