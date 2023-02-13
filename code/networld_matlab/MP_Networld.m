function [Networks_Time, Flag_End] = MP_Networld(N, beta, T_max)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MP_Networld: Main Program that computes a networld simulation
%Input variables:
%   N: Number of initial Nodes
%   Beta: Enviromental-Temperature factor
%   T_Max: Max. allowed steps

% Output variables:

%   Networks_Time: Networks (adj matrix) present in each time step.
%   Flag_End: condtition that caused the end of the simulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Initial variables
% L: cell array with a cell for each network, which in turn contains the
% adyacency matrix of the network (simply [0] for a single node)
for i = 1: N
    L{i} = 0; % for N=1e6 matlab: 0.7s vs python: 0.3s
end
% Networks_Time: cell array with a cell for each point in time, which
% corresponds to the L of that point in time
Networks_Time{1} = L;
Flags = [];
% P: matrix with Pij=1 for the forbidden network unions (a network with
% itself or a pair that has already been tried). Initialized to forbid only 
% the union of a network with itself
P = eye(N); % for N=1e6 matlab: 0.03s vs python: 0.023s
counter = 1; %Counter of time steps

%% Main Loop (Union & Partition of Networks)
while isequal(P,ones(N))==0 && counter <= T_max
    % P = equal(ones(N)) ~ all network unions have been tried
    % counter <= T_max ~ within simulation max time

    % R1, R2: indices (over P, L, ...) of a pair of networks to join
    [R1, R2] = MP_Select_Networks(P);

    % A,B: adyacency matrices of the networks
    A = L{R1}; %Network A
    B = L{R2}; % Network B

    %Union of Networks A and B
        % T: adj mat of final network
        % Union_Allow: 0 = not joined; 1 = joined
        % Fin_Union: flag indicating whether the process finished with an
        % exact result
    [T, Union_Allow, Fin_Union] = MP_Network_Union(A, B); %Try the union
    Flags = horzcat(Flags, Fin_Union);

    % The union is repeated until some network can be joined, thus, the
    % partition step, counter update, ... don't happen until the union has
    % been allowed
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
        L_new = MP_Network_Partition(L, beta);
        L = L_new;
        Networks_Time{end+1} = L;
        N = max(size(L));
        P = eye(N);
    else
        %The union was not possible
        P(R1,R2) = 1;
        P(R2,R1) = 1;
    end
end

if max(size(P)) == 1
    % Single network component
    Flag_End = 1;
elseif isequal(P,ones(N))
    % No connectable networks
    Flag_End = 2;
else
    % Reached max iter
    Flag_End = 3;
end





