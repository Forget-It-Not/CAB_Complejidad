function SCR_Process_Simulations(data_path)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SCR_Process_Simulations: script for processing the RAW output of a batch
% of networld simulations

% Input variables:
%   data_path: CHAR
%       Folder where RAW output is stored
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load global metadata (equivalence between networks and measures)
metadata_path = '~/Desktop/Ciencia_de_Datos/TFM/CAB_Complejidad/data/networld_metadata.mat';
load(metadata_path, 'Networks_Key', 'Networks_Unique', 'Networks_Measures')

raw_files = dir(fullfile(data_path, 'RAW*.mat'));
for i=1:length(raw_files)

    % Load RAW networld output
    name = raw_files(i).name;
    disp(strcat('Processing file: ', name))
    file = strcat(data_path, name);
    load(file, 'Networks');

    % Auxiliary data processing
    %   Networks found in the simulation are matched to the global metadata
    %   If the networks wasn't present the metadata is updated
    tic
    [Networks_Time, Networks_Key, Networks_Unique, Networks_Measures] = AUX_Process_RAW(Networks, Networks_Key, Networks_Unique, Networks_Measures);
    save(strcat(data_path, 'SRC_', name), "Networks_Time")
    save(metadata_path, 'Networks_Key', 'Networks_Unique', 'Networks_Measures')
    toc
end

% The updated metadata is saved 
disp(strcat('Updated metadata includes ', num2str(length(Networks_Key)), ' networks'))
save(metadata_path, 'Networks_Key', 'Networks_Unique', 'Networks_Measures')

end