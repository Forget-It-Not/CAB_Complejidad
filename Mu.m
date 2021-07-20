
function mu = Mu(A)
%% Computes the minimum nonzero eigenvalue of the Laplacian matrix
% Input: A matrix
% Output: mu

%%
if max(size(A)) ==1
    mu = 0;
else
L=-1*A+diag(sum(A));
D = eigs(L,2,'SA');
mu = D(2);
end
end