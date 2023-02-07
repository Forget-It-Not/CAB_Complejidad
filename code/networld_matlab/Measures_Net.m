
function Measures = Measures_Net(Network)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Measures_Net: Compute the measures (N: Size, Lambda 1, Lambda 2, Mu,
%Mean_Degree, H:Entropy) of a network

% Input:
    %Network: Matrix of a network
% Output:
    %Measures: Vector with the measures of the network
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 
if Network == 0 %Simple node
    Lambda1 = eigs(Network,1);
    Lambda2 = 0;
    
else
    Lambdas = eigs(Network,2,'LA');
    Lambda1 = norm(Lambdas(1),2);Lambda2 = norm(Lambdas(2),2);
end

N = max(size(Network));
mu = Mu(Network); % Laplacian
Deg = sum(Network,2); %Degree of each node
Gr_Medio = mean(Deg);
H = Entropy(Network);
Measures = [N,Lambda1, Lambda2, mu, Gr_Medio, H];

end