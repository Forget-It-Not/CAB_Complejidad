
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

[N,~] = size(A);
%%M%% input A (= previous P) is the network to network matrix that
%%indicates whether connection has been tried and prohibited

%%M%% Chossing a row = choosing a network; choose until the network is
%%connectable
R1 = randi(N); % We choose a first network at random
%%M%% if A(R1,:) has all ones it means all other networks have been already
%%tested for connection with R1
while A(R1,:) == ones(1,N)
    R1 = randi(N);
end
%%M%% Choose the second network from the set of other networks that are
%%connectable
x = find(~A(R1,:));  % Indices of the zeros of row R1
l = length(x);
R = randi(l);
R2 = x(R);
end