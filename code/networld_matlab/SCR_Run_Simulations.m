function SCR_Run_Simulations(N, beta, T_Max, nrep, out_path)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SCR_Run_Simulations: script for running a batch of Networld simulations

% Input variables:
%   N: INT [VECTOR]
%       Number or list of numbers of nodes
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
for betai = beta
for T_Maxi = T_Max
for ni = nrep

    infoline = strcat('Running Networld - N:', num2str(Ni), ' Beta:', ...
        num2str(betai), ' T_Maxi:', num2str(T_Maxi), ' Rep:', num2str(ni));
    disp(infoline)

    % Main Program Execution
    tic
    Networks = MP_Networld(Ni, betai, T_Maxi);
    toc

    % Storing RAW Output
    cd(out_path)
    File_Name = strcat('RAW_N', num2str(Ni), '_Beta', num2str(betai), '_TMax', num2str(T_Maxi), '_Rep', num2str(ni), '.mat');
    save(File_Name, 'Networks')
    cd(code_path)

end
end
end
end

end