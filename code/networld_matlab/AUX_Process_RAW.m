function [Networks_Time, Networks_Key, Networks_Unique, Networks_Measures] = AUX_Process_RAW(Networks, Networks_Key, Networks_Unique, Networks_Measures)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AUX_Process_RAW:
%   Processing of the RAW output of a Networld simulation

% Input Data:
%   Networks: list with a position for each time point of the simulation,
%   such that each position contains a list of the network adyacency
%   matrices present in that time point

%   Networks_Unique: Set of networks (their adj matrix) that have been
%   previously identified (across all simulation that have used the global
%   metadata)

%   Networks_Measures: Measures of each network that has been identified
%   (across all simulations that have used the global metadata)

%   Networks_Key: Equivalence key between the index of a network in
%   Networks_Measures and its identifier (= index in Networks_Unique). See
%   pseudocode for more information.

% Output Data:
%   Networks_Time: Row for each (repeated) network that appeared in the 
%   simulation, where the columns correspond to: t, NRed (references 
%   Network_Unique) and NRep (=1)

%   Metadata: Ídem as input but updated with the new networks found
%   in the simulation 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Networks_Time = [];
T = max(size(Networks));
for t = 1:T
    
    % Loop over the networks of a time point
    n = max(size(Networks{t}));
    for i = 1:n
        
        measures = AUX_Measures_Net(Networks{t}{i});

        % Check if the measure vector is present in the metadata
        present = 0;
        for j = 1:size(Networks_Measures, 1)
            alfa = norm(Networks_Measures(j,:)- measures,2);
            if alfa < 1e-12
                % If present its index is the network identifier given by
                % the Networks_Key
                network_id = Networks_Key(j);
                present = 1;
                break
            end
        end

        % If not present, add it to the metadata
        if present == 0
            % Network identifier is current number of networks +1
            network_id = size(Networks_Measures,1) +1;
            Networks_Measures(network_id,:) = measures;
            Networks_Unique{network_id} = Networks{t}{i};
            % The key will always be of type Key(i) = i until the metadata
            % is sorted
            Networks_Key(network_id) = network_id;
        end
        Networks_Time(end+1,:) = [t, network_id, 1];
    end
end

end
