
function [R1, R2] = MP_Select_Networks(P)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Select_Networks: From a square matrix P of 0s and 1s it selects an element
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

[N,~] = size(P);

% Choose a network of P until the network has other networks with which it
% may connect, which happens when there is some P(R1,i) = 0  
R1 = randi(N); 
while P(R1,:) == ones(1,N)
    R1 = randi(N);
end
%%M%% Choose the second network from the set of other networks that are
%%connectable
x = find(~P(R1,:));  % Indices of the zeros of row R1
l = length(x);
R = randi(l);
R2 = x(R);
end