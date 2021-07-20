
function [Table_Time,Table_Unique,Networs_Time, Networks_Unique]= Measures_Time(Networks)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Measures_Time: Given a set of Networks this programm compute the measures
% of each networks and saved on tables

% Input Data: 
%   Networks: {} set with each network that the process had in each time
%   step

% Output Data:
%   Table_Time: Matrix (each row correspond to a network and each column
%   correspond to a measures)

%   Table_Unique: Matrix with the same information as Table_Time but only
%   with unique (with out repetion) networks

%   Networks_Time: Set of networks corresponding to Table_Time, i.e, row i 
%   of Table_Time contains the measures of Networks_Time{i}

%   Networks_Unique: Set of networks corresponding to Table_Unique, i.e, row i 
%   of Table_Unique contains the measures of Networks_Time{i}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initial variables

T = max(size(Networks));
Table_Time = [];
Table_Unique = [];

%% Main Loop
for t = 1:T
    N = max(size(Networks{t}));
    Meas_T = zeros(N,9); %vector with the measures of the networks
    for i = 1:N
        Meas_T(i,1:end-1) = [t,i,Measures_Net(Networks{t}{i})];
    end

% For each time step We eliminante the repeted networks using the measures from  Meas_T(:,[3:9])

[T2,Indices_Save,Col_Num_Rep,IC] = Del_Repetitions(Meas_T(:,[3,4,6,7,8,9]),1e-12);

Table_Time = [Table_Time;[Meas_T(Indices_Save,1:end-1),Col_Num_Rep]]; 


% We eliminate again the repeted networks, now we do not take into account the time step

Table_Unique = [Table_Unique;[Meas_T(Indices_Save,1:end-1),Col_Num_Rep]];
[T2,Indices_Save,Col_Num_Rep,IC] = Del_Repetitions(Table_Unique(:,[3,4,6,7,8,9]),1e-12);
Table_Unique = [Table_Unique(Indices_Save,1:end-1),Col_Num_Rep];


end


%% Save the Networks from each time step
Networs_Time = {};
x = Table_Time(:,1);
y = Table_Time(:,2);

for i=1:length(x)
    Networs_Time{i} = Networks{x(i)}{y(i)};
end


%% Save the unique networks
Networks_Unique = {};
x = Table_Unique(:,1);
y = Table_Unique(:,2);
for i=1:length(x)
    Networks_Unique{i} = Networks{x(i)}{y(i)};
end

Table_Time = Table_Time(:,[1,3:end]);
Table_Unique = Table_Unique(:,[1,3:end]);
%% Sumamos 1 a las columnas de rep
Table_Time(:,end) = Table_Time(:,end)+1;
Table_Unique(:,end) = Table_Unique(:,end)+1;

end