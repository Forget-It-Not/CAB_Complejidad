function adj_mat = AUX_Edgelist2Adj(edgelist)
%AUX_EDGELIST2ADJ Summary of this function goes here
%   Detailed explanation goes here
if length(edgelist) == 0
    adj_mat = [0];
else
    n = max(edgelist(:));
    adj_mat = zeros(n);
    [n_links, ~] = size(edgelist);
    for i=1:n_links
        adj_mat(edgelist(i,1),edgelist(i,2)) = 1;
    end
    adj_mat = adj_mat + transpose(adj_mat);
end

end

