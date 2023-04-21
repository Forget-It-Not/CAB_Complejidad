function SCR_Run_Simulations(N, k, beta, T_Max, nrep, out_path)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SCR_Run_Simulations: script for running a batch of Networld simulations

% Input variables:
%   N: INT [VECTOR]
%       Number or list of numbers of nodes
%   k: FLOAT [VECTOR]
%       Value or list of values of the general union rate
%   Beta: FLOAT [VECTOR] 
%       Value or list of values of the Enviromental-Temperature factor
%   T_Max: INT [VECTOR]
%       Number or list of numbers of Max. allowed steps
%   nrep: INT [VECTOR]
%       Repetition index assigned to the simulation or a vector to perform
%       several repetitions of each parameter combination
%   out_path: CHAR
%       Folder where RAW output will be stored
%
%   NOTE: if several parameters are provided as lists, all possible
%   combinations of the values of all parameters will be used
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

code_path = pwd;

% For each combination of parameter values...
for Ni = N
for ki = k
for betai = beta
for T_Maxi = T_Max
for ni = nrep

    infoline = strcat('Running Networld - N:', num2str(Ni), ' k:', num2str(ki), ...
     ' Beta:', num2str(betai), ' T_Maxi:', num2str(T_Maxi), ' Rep:', num2str(ni));
    disp(infoline)

    % Main Program Execution
    tic
    Networks_Time = MP_Networld(Ni, ki, betai, T_Maxi);
    toc

    % Storing RAW Output
    cd(out_path)
    File_Name = strcat('SRC_N', num2str(Ni), '_K', num2str(ki), '_Beta', num2str(betai), '_TMax', num2str(T_Maxi), '_Rep', num2str(ni), '.mat');
    Networks_Time = array2table(Networks_Time, 'VariableNames', {'t', 'NRed', 'NRep'});
    writetable(Networks_Time, File_Name);
    cd(code_path)

end
end
end
end
end

end