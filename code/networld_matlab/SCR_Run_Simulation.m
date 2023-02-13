%% Model Variables
 nrep=1; N = 30; T_Max = 5000; beta = 0:0.1:3;

%% Output Directory
output_path = '/home/kiaran/Desktop/Ciencia_de_Datos/TFM/project/CAB_Complejidad/data/';
code_path = pwd;

%% Random seed
% stream = RandStream('mt19937ar','seed',sum(100*clock));
% RandStream.setDefaultStream(stream);

%% Run Simulation
for i = 1:length(beta)
    for j = 1:nrep
        Beta = beta(i);
        %%M%% tic ... toc: time execution
        tic
        [Networks, Flag_End] = MP_Networld(N, Beta, T_Max);
        disp 'MP_Networld Execution'
        toc 
    
        tic
        [Table_Time, Table_Unique, Networks_Time, Networks_Unique] = AUX_Measures_Time(Networks); %Computing the measures for each network
        Table_Time = array2table(Table_Time, 'VariableNames', {'T_step', 'N', 'Lambda1', 'Lambda2', 'Mu', 'GrMedio', 'Entropia', 'NumRep'});
        Table_Unique = array2table(Table_Unique, 'VariableNames', {'T_step', 'N', 'Lambda1', 'Lambda2', 'Mu', 'GrMedio', 'Entropia', 'NumRep'});
        disp 'Auxiliary data processing'
        toc 
    
        cd(output_path)
    
        File_Name = strcat('N', num2str(N), '_Beta', num2str(Beta), '_TMax', num2str(T_Max), '_Rep', num2str(j), ".mat");
        save(File_Name, 'Networks_Unique', 'Networks_Time', 'Table_Time', 'Table_Unique', ...
            'Beta', 'N', 'T_Max', 'Flag_End')
        
        cd(code_path)
    end
end

output_files = dir(fullfile(output_path, 'N30*.mat'));

%% Figure 2H
num_configs = [];
beta = [];
H = []
flag_end = [];
for i = 1:length(output_files)
    file = strcat(output_path, output_files(i).name);
    disp file
    load(file);
    num_configs(end+1) = max(size(Networks_Unique));
    beta(end+1) = Beta;
    flag_end(end+1) = Flag_End;
    n = Table_Unique.NumRep;
    p = n / sum(n);
    entropy = sum(-1 * p .* log2(p));
    H(end+1) = entropy / log2(max(size(p)));

end

figure(1)
scatter(beta, num_configs, 50, flag_end, 'filled');
cb = colorbar;
set(gca, 'YScale', 'log')

figure(2)
scatter(beta, H, 50, flag_end, 'filled');
cb = colorbar;

