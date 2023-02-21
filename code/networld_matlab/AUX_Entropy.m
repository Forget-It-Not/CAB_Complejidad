function H = AUX_Entropy(A)
%% Entropy
% Calculates the Shannon entropy of a network from its degree distribution
% Input:
% A: Network adjacency matrix
% H: Network entropy

%% 
H = 0;
[p, k] = AUX_Degree_Dist(A); %Degree distribution
for i = 1: length(p)
    if p(i) > 0
    H = H - p(i)*log2(p(i));
    end
end
end


