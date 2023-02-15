%% SCRIPT INFO %%
%%%%%%%%%%%%%%%%%

% Script used to obtain figures 2H and 3B of Networld's PNAS. Basic check
% that the model maintains desirable properties after being modified

% Input: simulation data obtained from SCR_Run_Simulation

%% Path of simulation data
data_path = '/home/kiaran/Desktop/Ciencia_de_Datos/TFM/project/CAB_Complejidad/data/';
% Use a pattern to only use a subset of files (e.g. only files with N=20)
data_files = dir(fullfile(data_path, 'N40*.mat'));

%% Load data
num_configs = [];
beta = [];
H = [];
% flag_end = []; used to check the reason the simulation ended

% Recover the appropriate variables from the mat files
for i = 1:length(data_files)
    file = strcat(data_path, data_files(i).name);
    load(file);
    num_configs(end+1) = max(size(Networks_Unique));
    beta(end+1) = Beta;
    % flag_ends(end+1) = Flag_End;

    % Normalized entropy calculations
    n = Table_Unique.NumRep; % number of copies of a network over time
    p = n / sum(n); % normalization, prob of finding a network
    entropy = sum(-1 * p .* log2(p));
    H(end+1) = entropy / log2(max(size(p))); % Normalized entropy
end

% H is nan when there is only a network due to the normalization, but the
% expected value would be 0
H(isnan(H)) = 0;


%% Inspection of results

% Check if there is a transition and its bounds
subplot(2,1,1);
scatter(beta, num_configs, 50, 'filled', 'MarkerFaceColor', [0 0.4470 0.7410]);
set(gca, 'YScale', 'log');
xlabel('beta');
ylabel('# Configurations');

subplot(2,1,2);
scatter(beta, H, 50, 'filled', 'MarkerFaceColor', [0 0.4470 0.7410]);
xlabel('beta');
ylabel('Normalized H');

%% Transition bounds 
pre_lim = 1.4;
pos_lim = 2.5;

% Subset of data pre and pos transition
beta_pre = beta(beta < pre_lim);
beta_pos = beta(beta >= pre_lim & beta < pos_lim);

num_configs_pre = num_configs(beta < pre_lim);
num_configs_pos = num_configs(beta >= pre_lim & beta < pos_lim);

H_pre = H(beta < pre_lim);
H_pos = H(beta >= pre_lim & beta < pos_lim);

% Linear regression pre and pos transition
    % For the number of configurations fit the logarithm
p_nc_pre = polyfit(beta_pre, log(num_configs_pre),1);
p_nc_pos = polyfit(beta_pos, log(num_configs_pos),1);
p_H_pre = polyfit(beta_pre,H_pre,1);
p_H_pos = polyfit(beta_pos,H_pos,1);

%% Final graphs
lr_pre_beta = [0.01, pre_lim+0.2];
lr_pos_beta = [pre_lim-0.2,pos_lim+0.2];

% Beta vs Nº Configs
lr_pre_nc = exp(lr_pre_beta*p_nc_pre(1) + p_nc_pre(2));
lr_pos_nc = exp(lr_pos_beta*p_nc_pos(1) + p_nc_pos(2));

lr_intersect = (p_nc_pre(2) - p_nc_pos(2)) / (p_nc_pos(1) - p_nc_pre(1));
fig_position = get(gca, 'Position');
ann_position = fig_position(1) + (lr_intersect/3)*fig_position(3);

subplot(2,1,1);
plot(lr_pre_beta, lr_pre_nc, 'Color', 'black', 'LineWidth', 2);
hold on
plot(lr_pos_beta, lr_pos_nc, 'Color', 'black', 'LineWidth', 2);
hold on
scatter(beta, num_configs, 50, 'filled', 'MarkerFaceColor', [0 0.4470 0.7410]);
set(gca, 'YScale', 'log');
annotation("textarrow",[ann_position,ann_position],[0.85,0.6],'String','\beta_{crit}','Color','red','LineStyle',':');
xlabel('beta');
ylabel('# Configurations');
xlim([0,3])

% Beta vs Norm H 
lr_pre_H = lr_pre_beta*p_H_pre(1) + p_H_pre(2);
lr_pos_H = lr_pos_beta*p_H_pos(1) + p_H_pos(2);

lr_intersect = (p_H_pre(2) - p_H_pos(2)) / (p_H_pos(1) - p_H_pre(1));
fig_position = get(gca, 'Position');
ann_position = fig_position(1) + (lr_intersect/3)*fig_position(3);

subplot(2,1,2);
plot(lr_pre_beta, lr_pre_H, 'Color', 'black', 'LineWidth', 2);
hold on
plot(lr_pos_beta, lr_pos_H, 'Color', 'black', 'LineWidth', 2);
hold on
scatter(beta, H, 50, 'filled', 'MarkerFaceColor', [0 0.4470 0.7410]);
annotation("textarrow",[ann_position,ann_position],[0.38,0.12],'String','\beta_{crit}','Color','red','LineStyle',':');
xlabel('beta');
ylabel('Normalized H');
xlim([0,3])
