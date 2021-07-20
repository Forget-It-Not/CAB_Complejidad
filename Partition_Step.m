
function New_Networks = Partition_Step(Networks,beta)

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

[~,Num_Netw] = size(Networks);
New_Networks ={};
p = zeros(1,Num_Netw); %Vector with the probabilities of partition of each netwoks
c = 1; %Counter

for i = 1:Num_Netw 
    mu = Mu(Networks{i});
    [n,~] = size(Networks{i});
    p(i) = 2*exp(-beta*mu)/(1+exp(-beta*mu)); %Probability of Partition
    %p(i) = 0; % Uncomment for Beta = Inf
    x = binornd(1,p(i)); %Decide if the network will break or not
    if x== 1 %Partition of the network
        partititions= partition_eigenvector(Networks{i}); %Set of networks af the partition 
        for j=1:length(partititions) 
            New_Networks{c} = partititions{j};
            c = c+1;
        end
    else
        New_Networks{c} = Networks{i};       
        c = c +1;
    end
end