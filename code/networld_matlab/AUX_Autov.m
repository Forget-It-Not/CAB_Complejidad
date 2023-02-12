

function [u_T, lambda_T] = AUX_Autov(A)
%%
%Compute the eigenvector assiacted with the largest eigenvalue and the eigvenctor
% of a adjacency matrix A.
%
% Input:
%   A: Adjacency Matrix
% Output
%   u_T: Eigenvector
%   lambda_T: Largest eigenvalue
%%
[W, D] = eig(A);% V eigenvector column % D diagonal matrix with eigenvalues
[lambda_T,Ind] =max(max(D)); %Largest Eigenvalue
V = W(:,Ind)';
u_T = abs(V); 
end