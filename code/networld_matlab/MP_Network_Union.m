
function [T_id, T_mat, Networks_Key, Networks_Unique, Networks_Measures] = ...
            MP_Network_Union(A, B, fraction, Networks_Key, Networks_Unique, Networks_Measures)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MP_Network_Union: 
%   Joins two networks A, B according to the simplified criterion of gaining 
%   centrality. The hubs of each network are connected to one another.

% Inputs:
%   A, B: Adjacency matrices of the networks.
%   fraction: fraction of all possible links that will be made
%   metadata: metdata tables used to identify the joined network
% Outputs:
%   T_id: identifier of the final network
%   T_mat: Adjacency matrix of the final network.
%   metadata: updated metadata
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Sizes of each network and minimum size (=nº links)
[na,~] = size(A);
[nb,~] = size(B);
nmin = min(na,nb);
nlinks = round(fraction*nmin);

% A1 = small network; A2 = big network
if na < nb
    A1 = A;
    A2 = B;
else
    A1 = B;
    A2 = A;
end

% Centralities of each network
cen1 = AUX_Centrality(A1);
cen2 = AUX_Centrality(A2);

% Ranking of the nodes of each network
[~, rank1] = sort(cen1, 'descend');
[~, rank2] = sort(cen2, 'descend');

% Top centrality nodes (the ones that will connect)
rank1 = rank1(1:nmin);
rank2 = rank2(1:nmin);

% Adj matrix of the union without links between networks
T_mat = blkdiag(A1,A2);

for i=1:nlinks
    % Nodes from the bigger network have index nmin + i (due to joining the
    % small network first and the big second)
    T_mat(rank1(i), nmin + rank2(i)) = 1;
    T_mat(nmin + rank2(i), rank1(i)) = 1;
end

T_meas = AUX_Measures_Net(T_mat);

% Check if the measure vector is present in the metadata
present = 0;
for j = 1:size(Networks_Measures, 1)
    alfa = norm(Networks_Measures(j,:)- T_meas,2);
    if alfa < 1e-12
        % If present its index is the network identifier given by
        % the Networks_Key
        T_id = Networks_Key(j);
        present = 1;
        break
    end
end

% If not present, add it to the metadata
if present == 0
    % Network identifier is current number of networks +1
    T_id = size(Networks_Measures,1) +1;
    Networks_Measures(T_id,:) = T_meas;
    %Networks_Unique{T_id} = T_mat;
    % The key will always be of type Key(i) = i until the metadata
    % is sorted
    Networks_Key(T_id) = T_id;
end
end

