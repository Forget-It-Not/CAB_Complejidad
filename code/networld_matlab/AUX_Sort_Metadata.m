function AUX_Sort_Metadata()

%
% AUX_Sort_Metadata:
%   Sorts the Network_Measures table in the global metadata (for now, by 
%   order of increasing nodes). 
%
%   Output processing scans this table in order to identify the networks,
%   and stops as soon as a match is found, meaning a properly sorted table
%   will speed up processing. 
%
%   As an heuristic, the table will be sorted by number of nodes, since 
%   networks will a smaller number of nodes will tend to be more frequent,
%   but may change later.
%

% Load global metadata
metadata_path = '~/Desktop/Ciencia_de_Datos/TFM/CAB_Complejidad/data/networld_metadata.mat';
load(metadata_path, 'Networks_Key', 'Networks_Unique', 'Networks_Measures')

% Sort according to ascending number of nodes
[~, index] = sort(Networks_Measures(:,1), 'ascend');
Networks_Measures = Networks_Measures(index,:);
% When metadata is sorted Networks_Key keeps the correspondence between the
% oriignal network identifier and the new Networks_Measures index
Networks_Key = Networks_Key(index);

% Save modified metadata back
save(metadata_path, 'Networks_Key', 'Networks_Unique', 'Networks_Measures')