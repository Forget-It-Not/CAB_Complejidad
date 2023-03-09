function SCR_Process_Simulations(data_path)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SCR_Process_Simulations: script for processing the RAW output of a batch
% of networld simulations (an experiment of sorts)

% Input variables:
%   data_path: CHAR
%       Folder where RAW output is stored
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load global network metadata
metadata_path = '~/Desktop/Ciencia_de_Datos/TFM/CAB_Complejidad/data/networld_metadata.mat';
load(metadata_path)

% Load RAW output
raw_sims = {};
raw_files = dir(fullfile(data_path, 'RAW*.mat'));
for i=1:length(raw_files)
    name = raw_files(i).name;
    disp(strcat('Loading file: ', name, '...'))
    file = strcat(data_path, name);
    load(file);
    raw_sims{end+1} = Networks;
end

disp 'Auxiliary data processing'
tic
[Networks_Unique, Networks_Measures, Simulations_Time] = AUX_Process_RAW(raw_sims);
toc

% Save metadata that is common for all simulations (set of networks that
% appeared and their corresponding measures)
save(strcat(data_path, 'network_metadata.mat'), 'Networks_Unique', 'Networks_Measures')

% For each simulation save the processed network profile over time
for i=1:length(Simulations_Time)
    name = raw_files(i).name;
    Networks_Time = Simulations_Time{i};
    save(strcat(data_path, 'SRC_', name), "Networks_Time")
end

end