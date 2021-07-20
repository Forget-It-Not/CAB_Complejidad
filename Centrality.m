
function C = Centrality(u_T,lambda_T, i)
% Function that compute the centrality
C =  lambda_T*u_T(i)/ norm(u_T, 1);
end

