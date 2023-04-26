function edgelist = AUX_Adj2Edgelist(adj_mat)

n = length(adj_mat);
edges = find(triu(adj_mat>0));
edgelist = [];
for e=1:length(edges)
    [i,j] = ind2sub([n,n], edges(e));
    edgelist = [edgelist; i j];
end