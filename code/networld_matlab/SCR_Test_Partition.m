%% SCRIPT INFO %%
%%%%%%%%%%%%%%%%%

% Script used to identify networks appearing in Networld that have
% modularity eigenvectors with zero values and test possible solutions

%% Network generation

% Runs networld simulations and prints network that have any V==0

n_simulations = 3;

problematic_networks = {};
for i = 1:n_simulations
    tic
    Networks = MP_Networld(N, Beta, T_Max);
    disp 'MP_Networld Execution'
    toc

    tic
    [Table_Time, Table_Unique, Networks_Time, Networks_Unique] = AUX_Measures_Time(Networks); %Computing the measures for each network
    Table_Time = array2table(Table_Time, 'VariableNames', {'T_step', 'N', 'Lambda1', 'Lambda2', 'Mu', 'GrMedio', 'Entropia', 'NumRep'});
    Table_Unique = array2table(Table_Unique, 'VariableNames', {'T_step', 'N', 'Lambda1', 'Lambda2', 'Mu', 'GrMedio', 'Entropia', 'NumRep'});
    disp 'Auxiliary data processing'
    toc 

    for network = Networks_Unique
        V = mod_eig(network);
        if any(V==0)
            problematic_networks{end+1} = network;
        end
    end

end

%% Plotting problematic networks 

% Plots problematic networks identified (the same network will be repeated
% for each simulation in which it appears, i don't think its worth
% repeating duplicates for this)

n = max(size(problematic_networks));
for i = 1:n
    subplot(ceil(sqrt(n)),ceil(sqrt(n)),i);
    G = graph(problematic_networks{i});
    plot(G);
end

%% Plotting partition outcomes

% Set a way to solve the problem in MP_Partition_Eigenvector (e.g. manual
% solution of problematic networks) and check the outcome

for i = 1:n
    subplot(n,2,i*2-1);
    G = graph(problematic_networks{i});
    plot(G);
    title('Input');
    partition = MP_Partition_Eigenvector(problematic_networks{i});
    new_network = blkdiag(partition{1},partition{2});
    subplot(n,2,i*2);
    G = graph(new_network);
    plot(G);
    title('Output');
end

%% Auxiliary functions

% Function to calculate the eigenvector of the modularity matrix (just a
% copy from MP_Partition_Eigenvector)

function V = mod_eig(network)
    A=network+diag(ones(size(network,1),1));
    k=sum(A);
    links=sum(sum(A))/2;
    B=A-(k'*k)/(2*links);
    [V,~]=eigs(B,[],1);
end

