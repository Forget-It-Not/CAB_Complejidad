%% SCRIPT INFO %%
%%%%%%%%%%%%%%%%%

% Script used to run Networld simulations and store the output so it can be
% analyzed later using Python (please, please, for god's sake, use Python)

%% Model Variables
 nrep=5; N = 40; T_Max = 5000; beta = 2.9:0.1:3; % 1.1:0.1:2

 independent_reps = false;

%% Output Directory
output_path = '/home/kiaran/Desktop/Ciencia_de_Datos/TFM/project/CAB_Complejidad/data/';
code_path = pwd;

%% Random seed
% stream = RandStream('mt19937ar','seed',sum(100*clock));
% RandStream.setDefaultStream(stream);

%% Run Simulation
for i = 1:length(beta)

    % If all repetitions are to be mixed, this variable will hold the
    % complete set of networks at each time
    Networks_Combined = {};

    disp(strcat('Running simulation for beta = ', num2str(beta(i))));

    for j = 1:nrep

        disp(strcat('Repetition number: ', num2str(j)))

        Beta = beta(i);
        %%M%% tic ... toc: time 

        % Execution of main program
        disp 'MP_Networld Execution'
        tic
        [Networks, ~] = MP_Networld(N, Beta, T_Max);
        toc

        % Storing the unprocessed output
        cd(output_path)
    
        File_Name = strcat('RAW_N', num2str(N), '_Beta', num2str(Beta), '_TMax', num2str(T_Max), '_Rep', num2str(j), ".mat");
        save(File_Name, 'Networks')
        
        cd(code_path)

        % Processing of output for independent repetitions 
        if independent_reps
            disp 'Auxiliary data processing'
            tic
            [Table_Time, Table_Unique, Networks_Time, Networks_Unique] = AUX_Measures_Time(Networks); %Computing the measures for each network
            Table_Time = array2table(Table_Time, 'VariableNames', {'T_step', 'N', 'Lambda1', 'Lambda2', 'Mu', 'GrMedio', 'Entropia', 'NumRep'});
            Table_Unique = array2table(Table_Unique, 'VariableNames', {'T_step', 'N', 'Lambda1', 'Lambda2', 'Mu', 'GrMedio', 'Entropia', 'NumRep'});
            toc 
    
            % Storing the output
            cd(output_path)
        
            File_Name = strcat('N', num2str(N), '_Beta', num2str(Beta), '_TMax', num2str(T_Max), '_Rep', num2str(j), ".mat");
            save(File_Name, 'Networks_Unique', 'Networks_Time', 'Table_Time', 'Table_Unique', ...
                'Beta', 'N', 'T_Max')
            
            cd(code_path)
        else
            Networks_Combined = [Networks_Combined, Networks];
        end
    end

    % Processing of output for mixed repetitions
    if ~ independent_reps
        disp 'Auxiliary data processing'
        tic
        [Table_Time, Table_Unique, Networks_Time, Networks_Unique] = AUX_Measures_Time(Networks_Combined); %Computing the measures for each network
        Table_Time = array2table(Table_Time, 'VariableNames', {'T_step', 'N', 'Lambda1', 'Lambda2', 'Mu', 'GrMedio', 'Entropia', 'NumRep'});
        Table_Unique = array2table(Table_Unique, 'VariableNames', {'T_step', 'N', 'Lambda1', 'Lambda2', 'Mu', 'GrMedio', 'Entropia', 'NumRep'});
        toc 

        % Storing the output
        cd(output_path)
    
        File_Name = strcat('N', num2str(N), '_Beta', num2str(Beta), '_TMax', num2str(T_Max), ".mat");
        save(File_Name, 'Networks_Unique', 'Networks_Time', 'Table_Time', 'Table_Unique', ...
            'Beta', 'N', 'T_Max')
        
        cd(code_path)
    end
end


%% Alternative Processing of RAW files
raw_files = dir(fullfile(output_path, 'RAW_N40*_TMax10000*.mat'));

for i = 1:length(raw_files)
    name = raw_files(i).name;
    file = strcat(output_path, name);
    load(file);

    disp(name)
    tic
    [Networks_Unique, Networks_Measures, Networks_Time] = AUX_Process_RAW(Networks);
    % Storing the output
    cd(output_path)
    toc

    info = strsplit(name, '_');
    N = info{2}(2:end);
    Beta = info{3}(5:end);
    T_Max = info{4}(5:end);
    j = info{5}(4:end-4);
    File_Name = strcat('N', N, '_Beta', Beta, '_TMax', T_Max, '_Rep', num2str(j), "_alt.mat");
    save(File_Name, 'Networks_Unique', 'Networks_Time', 'Networks_Measures')
    
    cd(code_path)
end
