function [Networks_Unique, Networks_Measures, Simulations_Time] = AUX_Process_RAW(RAW_sims)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AUX_Process_RAW:
%   Processing of the RAW output of Networld simulations (collection of 
%   network adyacency matrices for each time point)

% Input Data:
%   RAW_sims: {... , {...}, ...} list of Networld RAW simulations (cell
%   array with the output of MP_Networld)

% Output Data:
%   Networks_Unique: Set of networks (their adj matrix) that appeared in
%   the simulations

%   Networks_Measures: Measures of each network that appeared in the 
%   simulations, where the row number corresponds to its index in Networks
%   Unique

%   Simulations_Time: list of processed Networld simulations, where each
%   simulation corresponds to a Networks_Time table

%   Networks_Time: Row for each (repeated) network that appeared in the 
%   simulation, where the columns correspond to: t, NRed (references 
%   Network_Unique) and NRep (=1)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Networks_Unique = {};
Networks_Measures = [];
Simulations_Time = {};
next_index = 1;

% Loop over simulations
NSims = max(size(RAW_sims));
for nsim = 1:NSims
    Simulations_Time{nsim} = [];
    Networks = RAW_sims{nsim};

    % Loop over the time points of a simulation
    T = max(size(Networks));
    for t = 1:T

        % Loop over the networks of a time point
        n = max(size(Networks{t}));
        for i = 1:n
            
            measures = AUX_Measures_Net(Networks{t}{i});
            present = 0;
            for j = 1:next_index-1
                alfa = norm(Networks_Measures(j,:)- measures,2);
                if alfa < 1e-12
                    current_index = j;
                    present = 1;
                    break
                end
            end
            if present == 0
                Networks_Measures(next_index,:) = measures;
                Networks_Unique{next_index} = Networks{t}{i};
                current_index = next_index;
                next_index = next_index +1;
            end
            Simulations_Time{nsim}(end+1,:) = [t, current_index, 1];
        end
    end
end

end