%%M%%
    % Output: Networks_Time, L
    % Input: N, beta, T_max
function [Networks_Time,L]=Main_Process(N,beta, T_max)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main_Process: Main Programm to compute 1 process
%Input variables:
%   N: Number of initial Nodes
%   Beta: Enviromental-Temperature factor
%   T_Max: (Max. allowed steps)

% Output variables:

%   Redes_Tiempos: Networks appeared in each time step.
%   L: Networks that appeared in the final step.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Initial variables
Networks_Time= {};
for i = 1: N
    L{i} = 0; % Nodos sueltos
    Networks_Time{1}{i} = L{i}; %Initial networks are nodes.
end
Flags = [];

%%M%% 
    % L: cell array con una celda por red que a su vez contiene la matriz
    % de incidencia de la red (para un nodo suelto es simplemente el [0])

    % Networks_Time: cell array con una celda por cada punto de tiempo que
    % corresponde a la L de ese punto de tiempo

%%M%% Prohibition of union matrix (1 for pairs of networks that can't be
%%joined)
P = eye(N); % Identity matrix
counter = 1; %Counter of time steps

%% Main Loop (Union & Partition of Networks)
%%M%% While not all possible network unions have been prohibited...
while isequal(P,ones(N))==0 && counter <= T_max

    % The proccess of Union  and Partition is reapeted until no union is
    % possible or until we excess the number of maximum steps allowed(T_Max)

    %We choose 2 random networks to try the union
    %%M%% Ri are the indexes of the networks (disconnected componentes that
    %%would be numbered)
    [R1, R2] = Select_Networks(P);
    A = L{R1}; %Network A
    B = L{R2}; % Network B

    %Union of Networks A and B
    %%M%%
        % T: adj mat of final network
        % Union_Allow: 0 = not joined; 1 = joined
        % Fin_Union: flag con condiciones en que ha terminado el proceso???
    [T,Union_Allow,Fin_Union] =  Union(A, B); %Try the union
    %%M%% Hace una especie de vector poniendo los 2 valores uno al lado del
    %%otro
    Flags = horzcat(Flags,Fin_Union);


    if Union_Allow == 1
        counter = counter +1;
        %If the union is posible we take the joined network and mov to the
        %partition step
        
        L{R1} = T;
        %%M%% Al asignar [] la posición no queda con una lista vacia sino
        %%que desparece
        L(R2) = [];
        %Partimos las redes
        %%M%% Partition es simplemente el nuevo L tras la particion
        Partition = Partition_Step(L,beta);
        Networks_Time{end+1} = Partition;
        L = Partition;
        N = max(size(L));
        P = eye(N);
    else
        %The union was not possible
        P(R1,R2) = 1;
        P(R2,R1) = 1;
        %Flags = horzcat(Flags, 4);
    end
end




