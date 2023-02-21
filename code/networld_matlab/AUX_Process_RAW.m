function [Networks_Unique, Networks_Measures, Networks_Time] = AUX_Process_RAW(Networks)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AUX_Process_RAW:
%   Processing of the RAW output of Networld simulations (array of arrays 
%   with the adj matrix of each network)

% Input Data:
%   Networks: {} set with each network that the process had in each time
%   step

% Output Data:
%   Networks_Unique: Set of networks (their adj matrix) that appeared in
%   the simulation

%   Networks_Measures: Measures of each network that appeared in the 
%   simulation, where the row number corresponds to its index in Networks
%   Unique

%   Networks_Time: Row for each (repeated) network that appeared in the 
%   simulation, where the columns correspond to: t, NRed (references 
%   Network_Unique) and NRep (=1)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Networks_Unique = {};
Networks_Measures = [];
Networks_Time = [];
next_index = 1;

T = max(size(Networks));
for t = 1:T
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
        Networks_Time(end+1,:) = [t, current_index, 1];
    end
end

end