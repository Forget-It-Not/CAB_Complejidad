function [p,k]=Degree_Dist(A)
%% Computes the degree distribution of network with adjacency matrix A
% Input:
%   A: Adjacency Matrix
% Output:
%   p: Vector with probabilities
%   k: Vector with degrees

%%
n = max(size(A)); %Número of Nodes
Deg = sum(A,2); %Degree of each nodo
p = zeros(1,n);
for i = 1:n
    if Deg(i) ~= 0
    p(Deg(i)) = p(Deg(i))+1;
    end
end
p = p./n;
k = 1:1:n;
end