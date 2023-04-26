function adj_mat = AUX_Edgelist2Adj(edgelist)
%AUX_EDGELIST2ADJ Summary of this function goes here
%   Detailed explanation goes here
n = max(edgelist(:));
adj_mat = zeros(n);
for i=1:length(edgelist)
    adj_mat(edgelist(i,1),edgelist(i,2)) = 1;
end
adj_mat = adj_mat + transpose(adj_mat);
end

