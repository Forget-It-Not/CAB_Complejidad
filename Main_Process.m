function [Networks_Time,L]=Main_Process(N,beta, T_max)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main_Process: Main Programm to compute 1 process 
%Input variables:
%   N: Number of initial Nodes
%   Beta: Enviromental-Temperature factor
%   T_Max: (Max. allowed steps)

% Output variables:

%   Redes_Tiempos: Networks appeared in each time step.
%   L: Networks that appeared in the final step.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Initial variables
Networks_Time= {}; 
for i = 1: N
    L{i} = 0; % Nodos sueltos
    Networks_Time{1}{i} = L{i}; %Initial networks are nodes.
end
Flags = [];

P = eye(N); % Identity matrix
counter = 1; %Counter of time steps

%% Main Loop (Union & Partition of Networks)
while isequal(P,ones(N))==0 && counter <= T_max 
    
% The proccess of Union  and Partition is reapeted until no union is
% possible or until we excess the number of maximum steps allowed(T_Max)
   
%We choose 2 random networks to try the union
[R1, R2] = Select_Networks(P);
A = L{R1}; %Network A
B = L{R2}; % Network B

%Union of Networks A and B
[T,Union_Allow,Fin_Union] =  Union(A, B); %Try the union
Flags = horzcat(Flags,Fin_Union);


if Union_Allow == 1    
counter = counter +1;
%If the union is posible we take the joined network and mov to the
%partition step

    L{R1} = T;
    L(R2) = [];
    %Partimos las redes    
    Partition = Partition_Step(L,beta);
    Networks_Time{end+1} = Partition;
    L = Partition;
    N = max(size(L));
    P = eye(N);
else
    %The union was not possible
    P(R1,R2) = 1;
    P(R2,R1) = 1;
%Flags = horzcat(Flags, 4);
end
end




