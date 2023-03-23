
function T = MP_Network_Union(A, B)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MP_Network_Union: 
%   Joins two networks A, B according to the simplified criterion of gaining 
%   centrality. The hubs of each network are connected to one another.

% Inputs:
%   A, B: Adjacency matrices of the networks.
% Outputs:
%    T: Adjacency matrix of the final network.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Sizes of each network and minimum size (=nº links)
[na,~] = size(A);
[nb,~] = size(B);
nmin = min(na,nb);

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
T = blkdiag(A1,A2);

for i=1:nmin
    % Nodes from the bigger network have index nmin + i (due to joining the
    % small network first and the big second)
    T(rank1(i), nmin + rank2(i)) = 1;
    T(nmin + rank2(i), rank1(i)) = 1;
end

end

