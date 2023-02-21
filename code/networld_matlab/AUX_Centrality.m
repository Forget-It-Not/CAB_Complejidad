
function W = AUX_Centrality(T)
% Function that compute the centrality
[u, lambda] = AUX_Autov(T);
W = lambda * u ./ norm(u, 1);
end

