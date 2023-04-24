
function [net_ids_new, net_mats_new, Networks_Key, Networks_Unique, Networks_Measures] = ...
        MP_Network_Partition(net_ids, net_mats, beta, Networks_Key, Networks_Unique, Networks_Measures)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% MP_Network_Partition:  
%   Programm that correspond with the Partion Process, It
%   tries the partition of every network

% Input:
%   net_ids: Identifiers of networks in the environment
%   net_mats: Adyacency matrices of networks in the environment
%   beta: Enviromental- Temperature parameter. Associated with the
%   probrability of partition of a specific network p= 2*exp(-beta*mu)/(1+exp(-beta*mu));
%   For beta=inf uncomment line
%   metadata: metdata tables used to identify the new networks
% Output:
%   net_ids_new: Identifiers of new networks in the environment
%   net_mats_new: Adyacency matrices of new networks in the environment
%   metadata: updated metadata
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Num_Netw = length(net_ids);
net_ids_new = [];
net_mats_new = {};
p = zeros(1, Num_Netw); %Vector with the probabilities of partition of each netwok
c = 1; %Counter

%%M%% All networks are tested for partitioning; If a matrix splits the 
%%resulting incidence matrices go into new networks and otherwise goes the
%%original inc mat
for i = 1:Num_Netw
    mu = AUX_Compute_Mu(net_mats{i});
    [n,~] = size(net_mats{i});
    if isinf(beta)
        p(i) = 0;
    else
        p(i) = exp(-beta*mu);
    end
    x = binornd(1, p(i)); % Sample 0/1 according to the probability
    if x == 1 && n>1 %Partition of the network
        new_networks = MP_Partition_Eigenvector(net_mats{i}); %Set of networks af the partition
        for j=1:length(new_networks)
            
            new_meas = AUX_Measures_Net(new_networks{j});

            % Check if the measure vector is present in the metadata
            present = 0;
            for k = 1:size(Networks_Measures, 1)
                alfa = norm(Networks_Measures(k,:)- new_meas,2);
                if alfa < 1e-12
                    % If present its index is the network identifier given by
                    % the Networks_Key
                    new_id = Networks_Key(k);
                    present = 1;
                    break
                end
            end
            
            % If not present, add it to the metadata
            if present == 0
                % Network identifier is current number of networks +1
                new_id = size(Networks_Measures,1) +1;
                Networks_Measures(new_id,:) = new_meas;
                Networks_Unique{new_id} = new_networks{j};
                % The key will always be of type Key(i) = i until the metadata
                % is sorted
                Networks_Key(new_id) = new_id;
            end

            net_ids_new(c) = new_id;
            net_mats_new{c} = new_networks{j};
            c = c+1;
        end
    else
        net_ids_new(c) = net_ids(i);
        net_mats_new{c} = net_mats{i};
        c = c +1;
    end
end