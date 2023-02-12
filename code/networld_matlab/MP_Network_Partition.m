
function [L_new] = MP_Network_Partition(L, beta)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Partition_Step:  Programm that correspond with the Partion Process, It
%tries the partition of every network

% Input:
% Networks: Set {} of networks
% beta: Enviromental- Temperature parameter. Associated with the
% probrability of partition of a specific network p= 2*exp(-beta*mu)/(1+exp(-beta*mu));
% For beta=inf uncomment line
% Output:
% New_Networks: Set {} of new networks after the partition process

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

[~, Num_Netw] = size(L);
L_new ={};
p = zeros(1, Num_Netw); %Vector with the probabilities of partition of each netwok
c = 1; %Counter

%%M%% All networks are tested for partitioning; If a matrix splits the 
%%resulting incidence matrices go into new networks and otherwise goes the
%%original inc mat
for i = 1:Num_Netw
    mu = MP_Compute_Mu(L{i});
    [n,~] = size(L{i});
    if isinf(beta)
        p(i) = 0;
    else
        p(i) = 2*exp(-beta*mu)/(1+exp(-beta*mu));
    end
    x = binornd(1, p(i)); %Decide if the network will break or not
    if x == 1 %Partition of the network
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