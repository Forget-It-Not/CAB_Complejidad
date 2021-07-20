
function [R1,R2] = Select_Networks(A)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Select_Networks: From a square matrix A of 0s and 1s it selects an element
%which is non-zero A(i,j)!=0 . The indices (i,j) are the output of this
%function. This is used to select 2 networks i and j for the union step.
%The matrix keeps track of the unions that were tried.

%Input: 
%   A: Matrix of 0s and 1s. An element A (i, j) = 0 if the union of networks
% i and j has not been tried.

%Output:
% R1: Index of the first network
% R2: Index of the second network 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%

[N,~] = size(A);
R1 = randi(N); % We choose a first network at random
while A(R1,:) == ones(1,N)
    R1 = randi(N);
end
x = find(~A(R1,:));  % Indices of the zeros of row R1
l = length(x);
R = randi(l);
R2 = x(R);
end