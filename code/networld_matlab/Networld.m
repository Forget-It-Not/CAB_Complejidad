function Networld(Data_Name)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Main program: Uses the rest of the functions to compute the finale data.
    % The programa repits the process starting with N nodes, Beta (beta factor)
    % and T_Max (Max. allowed steps)

    %Input vars:
    %   Data_Name: Name which will recieve the file with the output data

    %Output:
    % Files containing:
    %   Beta
    %   N: Number of initial nodes
    %   T_Max: Maximum number of time steps allowed

    %   Table_Time: Matrix (each row correspond to a network and each column
    %   correspond to a measures)

    %   Table_Unique: Matrix with the same information as Table_Time but only
    %   with unique (with out repetion) networks

    %   Networks_Time: Set of networks corresponding to Table_Time, i.e, row i
    %   of Table_Time contains the measures of Networks_Time{i}

    %   Networks_Unique: Set of networks corresponding to Table_Unique, i.e, row i
    %   of Table_Unique contains the measures of Networks_Time{i}

    % The output files are saved inside the "Data" Folder.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %% Variables
    N = 20; T_Max = 5000; beta = 0:0.2:3;

    %% Create output directory if it doesnt exist
    

    %%M%% Random seed
    % stream = RandStream('mt19937ar','seed',sum(100*clock));
    % RandStream.setDefaultStream(stream);

    %% Main Loop
    for i = 1:length(beta)
        Beta = beta(i);
        %%M%% Start timing execution
        tic
        Networks = Main_Process(N, Beta, T_Max); %Networks from the process

        [Table_Time, Table_Unique, Networks_Time, Networks_Unique] = Measures_Time(Networks); %Computing the measures for each network

        Table_Time = array2table(Table_Time, 'VariableNames', {'T_step', 'N', 'Lambda1', 'Lambda2', 'Mu', 'GrMedio', 'Entropia', 'NumRep'});
        Table_Unique = array2table(Table_Unique, 'VariableNames', {'T_step', 'N', 'Lambda1', 'Lambda2', 'Mu', 'GrMedio', 'Entropia', 'NumRep'});

        %%M%% End and report execution time
        toc

        cd('../../data');

        File_Name = strcat('OLD_N', num2str(N), '_Beta_', num2str(Beta), '_TMax', num2str(T_Max), ".mat");
        save(File_Name, 'Networks_Unique', 'Networks_Time', 'Table_Time', 'Table_Unique', ...
            'Beta', 'N', 'T_Max')
        cd ..
        cd('code/networld_matlab/')
    end

end
