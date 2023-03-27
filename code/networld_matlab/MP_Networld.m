function [Networks_Time] = MP_Networld(N, beta, T_max)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MP_Networld: Main Program that computes a networld simulation
% Input variables:
%   N: Number of initial Nodes
%   beta: Enviromental-Temperature factor
%   T_Max: Max. allowed steps

% Output variables:
%   Networks_Time: Networks (adj matrix) present in each time step.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Initial variables
% L: cell array with a cell for each network, which in turn contains the
% adyacency matrix of the network (simply [0] for a single node)
for i = 1:N
    L{i} = 0; % for N=1e6 matlab: 0.7s vs python: 0.3s
end
num_nets = length(L);

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
while counter <= T_max %&& isequal(P,ones(N))==0  // PARA QUE PARE AL ALCANZAR UNA RED COMPLETA
    % P = equal(ones(N)) ~ all network unions have been tried
    % counter <= T_max ~ within simulation max time

    freq_u = (num_nets^2) / (4*N);
    num_unions = poissrnd(freq_u);

    for i = 1:num_unions
        if all(P(:)==1)
            break
        end

        % Incorrecto, aqui puede seleccionar un producto de union para la siguiente union ¡CAMBIAR!
        [R1, R2] = MP_Select_Networks(P);
        P(R1,:) = 1;
        P(:,R1) = 1;
        P(R2,:) = 1;
        P(:,R2) = 1;

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

        if Union_Allow == 1 %&& Fin_Union ~= 2  // PARA QUE SOLO ACEPTE UNIONES SI SE ALCANZA EL EQUILIBRIO DE NASH
            L{R1} = T;
            L{R2} = [];
        end
    end

    empty_idx = cellfun('isempty', L);
    L(empty_idx) = [];

    L_new = MP_Network_Partition(L, beta);
    L = L_new;

    Networks_Time{end+1} = L;
    num_nets = max(size(L));
    P = eye(num_nets);
    counter = counter+1;

end
end





