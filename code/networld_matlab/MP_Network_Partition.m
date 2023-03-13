
function [L_new, num_part] = MP_Network_Partition(L, beta)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% MP_Network_Partition:  
%   Programm that correspond with the Partion Process, It
%   tries the partition of every network

% Input:
%   L: Set {} of networks
%   beta: Enviromental- Temperature parameter. Associated with the
%   probrability of partition of a specific network p= 2*exp(-beta*mu)/(1+exp(-beta*mu));
%   For beta=inf uncomment line
% Output:
%   L_new: Set {} of new networks after the partition process

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

[~, Num_Netw] = size(L);
L_new ={};
p = zeros(1, Num_Netw); %Vector with the probabilities of partition of each netwok
c = 1; %Counter
num_part = 0;

%%M%% All networks are tested for partitioning; If a matrix splits the 
%%resulting incidence matrices go into new networks and otherwise goes the
%%original inc mat
for i = 1:Num_Netw
    mu = AUX_Compute_Mu(L{i});
    [n,~] = size(L{i});
    if isinf(beta)
        p(i) = 0;
    else
        p(i) = 2*exp(-beta*mu)/(1+exp(-beta*mu));
    end
    x = binornd(1, p(i)); % Sample 0/1 according to the probability
    if x == 1 %Partition of the network
        num_part = num_part + 1;
        new_networks = MP_Partition_Eigenvector(L{i}); %Set of networks af the partition
        for j=1:length(new_networks)
            L_new{c} = new_networks{j};
            c = c+1;
        end
    else
        L_new{c} = L{i};
        c = c +1;
    end
end