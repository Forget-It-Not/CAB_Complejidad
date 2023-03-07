%% SCRIPT INFO %%
%%%%%%%%%%%%%%%%%

% Script used to obtain figures 2H and 3B of Networld's PNAS. Basic check
% that the model maintains desirable properties after being modified

% Input: simulation data obtained from SCR_Run_Simulation

%% Path of simulation data
data_path = '/home/kiaran/Desktop/Ciencia_de_Datos/TFM/project/CAB_Complejidad/data/';
% Use a pattern to only use a subset of files (e.g. only files with N=20)
data_files = dir(fullfile(data_path, 'N40*.mat'));

%% Load data

% Recover the appropriate variables from the mat files
for i = 1:length(data_files)
    file = strcat(data_path, data_files(i).name);
    disp(data_files(i).name)
    load(file);

    % Normalized entropy calculations
    n = Table_Unique.NumRep; % number of copies of a network over time
    p = n / sum(n); % normalization, prob of finding a network
    Table_Unique.p = p;

    file = strcat(data_path, 'ABDATA_', data_files(i).name);
    save(file, 'Networks_Unique')
    file = strrep(file, '.mat', '.csv');
    writetable(Table_Unique, file)
end
disp 'Fin'

%% Check abundance info

beta=2.2;
load(strcat(data_path,'ABDATA_N40_Beta', num2str(beta), '_TMax5000.mat'))

figure
pairplot(Table_Unique)