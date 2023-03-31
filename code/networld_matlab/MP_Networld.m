function [Networks_Time] = MP_Networld(N, beta, T_max)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MP_Networld: Main Program that computes a networld simulation
% Input variables:
%   N: Number of initial Nodes
%   beta: Enviromental-Temperature factor
%   T_Max: Max. allowed steps

% Output variables:
%   Networks_Time: Row for each (repeated) network that appeared in the 
%   simulation, where the columns correspond to: t, NRed (references 
%   Network_Unique) and NRep (=1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

metadata_path = '../../data/networld_metadata.mat';
load(metadata_path)

%% Initial variables
% net_ids: vector with the id of each network (id of single node = 1)
% net_mats: cell array with the adyacency matrix of each network ([0] for single node)
net_ids = ones(1,N);
for i = 1:N
    net_mats{i} = 0; % for N=1e6 matlab: 0.7s vs python: 0.3s
end
num_nets = N;

% Initial time, network id and nº copies are all 1s for the first step
Networks_Time = [ones(N,1),net_ids(:),ones(N,1)];

% P: matrix with Pij=1 for the forbidden network unions (a network with
% itself or a pair that has already been tried). Initialized to forbid only 
% the union of a network with itself
P = eye(N);
counter = 1; %Counter of time steps

%% Main Loop (Union & Partition of Networks)
while counter <= T_max %&& isequal(P,ones(N))==0  // PARA QUE PARE AL ALCANZAR UNA RED COMPLETA
    % counter <= T_max ~ within simulation max time
    % P = equal(ones(N)) ~ no new union is possible

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
        A = net_mats{R1}; %Network A
        B = net_mats{R2}; % Network B
        
        %Union of Networks A and B
        %%% FOR ALL POSSIBLE LINKS
        % [T, Networks_Key, Networks_Unique, Networks_Measures] = ...
        %    MP_Network_Union(A, B, 1, Networks_Key, Networks_Unique, Networks_Measures); 
        %%% FOR 2/3s OF POSSIBLE LINKS
        [T_id, T_mat, Networks_Key, Networks_Unique, Networks_Measures] = ...
            MP_Network_Union(A, B, 0.67, Networks_Key, Networks_Unique, Networks_Measures); 
        
        net_ids(R1) = T_id;
        net_mats{R1} = T_mat;
        net_ids(R2) = nan;
        net_mats{R2} = [];
    end

    empty_idx = isnan(net_ids);
    net_ids(empty_idx) = [];
    net_mats(empty_idx) = [];

    [net_ids_new, net_mats_new, Networks_Key, Networks_Unique, Networks_Measures] = ...
        MP_Network_Partition(net_ids, net_mats, beta, Networks_Key, Networks_Unique, Networks_Measures); 
    net_ids = net_ids_new;
    net_mats = net_mats_new;

    num_nets = length(net_ids);
    P = eye(num_nets);
    counter = counter + 1;

    next_block = [ones(num_nets,1)*counter,net_ids(:),ones(num_nets,1)];
    Networks_Time = [Networks_Time; next_block];

end

save(metadata_path, 'Networks_Key', 'Networks_Unique', 'Networks_Measures')

end





