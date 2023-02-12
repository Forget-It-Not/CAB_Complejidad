
function W = MP_Centrality(T)
% Function that compute the centrality
[u, lambda] = MP_Autov(T);
W = lambda * u ./ norm(u, 1);
end

