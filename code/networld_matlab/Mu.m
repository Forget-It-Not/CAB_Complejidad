
function mu = Mu(A)
%% Computes the minimum nonzero eigenvalue of the Laplacian matrix
% Input: A matrix
% Output: mu

%%M%% Las redes con un solo nodo que tienen tamaño 1 no se pueden someter a
%%descomposición espectral asi que se asigna mu=0 directamente
if max(size(A)) ==1
    mu = 0;
else
    %%M%% L = matriz laplaciana, D = autovalores
    L=-1*A+diag(sum(A));
    D = eigs(L,2,'SA');
    mu = D(2);
end
end