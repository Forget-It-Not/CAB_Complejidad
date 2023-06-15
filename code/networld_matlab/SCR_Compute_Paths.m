layer_paths = {{[1]}};
layer_unions = {};
network_pool = [1];

curr_layer = 1;

layer_path = '../../data/layer_aux_metadata.mat';
load(layer_path)

metadata_path = '../../data/networld_metadata.mat';
load(metadata_path)

unions = [];
partitions = [];


% Loop over layers (networks generated with the same number of steps)
while True
    % Define possible unions

    % Loop over networks of the current number of steps being processed
    head_paths = layer_paths{curr_layer};
    for i = 1:length(head_paths)
        head_path = head_paths{i};
        head = head_path(end);

        % Join each new network with itself
        if length(layer_unions) < curr_layer + 1
            layer_unions{curr_layer+1} = [head,head];
        else
            layer_unions{curr_layer+1} = [layer_unions{curr_layer+1}; head,head];
        end
        if length(layer_paths) < curr_layer + 1
            layer_paths{curr_layer+1} = {head_path};
        else
            layer_paths{curr_layer+1}{end+1} = head_path;
        end
        
        % Join each new network with all previous networks
        for pre_layer = 1:(curr_layer-1)
            others_paths = layer_paths{pre_layer};
            for j=1:length(others_paths)
                other_path = others_paths{j};
                other = other_path(end);
                comb_path = union(head_path, other_path);
                layer = length(comb_path) + 1;

                if length(layer_unions) < layer
                    layer_unions{layer} = [head,other];
                else
                    layer_unions{layer} = [layer_unions{layer}; head,other];
                end
                if length(layer_paths) < layer
                    layer_paths{layer} = {comb_path};
                else
                    layer_paths{layer}{end+1} = comb_path;
                end
            end
        end
        
        % Join each network with all other networks from the same layer
        for j = (i+1):length(head_paths)
            other_path = head_paths{j};
            other = other_path(end);
            comb_path = union(head_path, other_path);
            layer = length(comb_path) + 1;

            if length(layer_unions) < layer
                layer_unions{layer} = [head,other];
            else
                layer_unions{layer} = [layer_unions{layer}; head,other];
            end
            if length(layer_paths) < layer
                layer_paths{layer} = {comb_path};
            else
                layer_paths{layer}{end+1} = comb_path;
            end
        end
    end

    % Compute partitions
    for i = 1:length(head_paths)
        head_path = head_paths{i};
        head = head_path(end);

        mat = AUX_Edgelist2Adj(Networks_Unique{head});
        curr_part = MP_Partition_Eigenvector(mat);
        partition_ids = [];
        for j = 1:length(curr_part)
            Tmat = curr_part{j};
            new_meas = AUX_Measures_Net(Tmat);

            present = 0;
            for k=1:size(Networks_Measures, 1)
                alfa = norm(Networks_Measures(k,:)-new_meas, 2);
                if alfa < 1e-12
                    new_id = Networks_Key(k);
                    present = 1;
                    break
                end
            end

            if present == 0
                new_id = size(Networks_Measures,1) +1;
                Networks_Measures(new_id,:) = new_meas;
                new_edgelist = AUX_Adj2Edgelist(Tmat);
                Networks_Unique{new_id} = new_edgelist;
                Networks_Key(new_id) = new_id;
            end
            partition_ids = [partition_ids, new_id];
        end

        partition_ids = unique(partition_ids);

        for j=1:length(partition_ids)
            new_id = partition_ids(j);
            present = false;
            for k=1:length(network_pool)
                if network_pool(k) == new_id
                    present=true;
                    break
                end
            end
            if present == false
                network_pool = [network_pool, new_id];
                layer_paths{curr_layer+1}{end+1} = [head_path, new_id];
            end

            partitions = [partitions; head, new_id, curr_layer+1];
        end

    end

    % Compute unions
    curr_layer = curr_layer + 1;

    curr_unions = layer_unions{curr_layer};
    [n_unions, ~] = size(curr_unions);
    for i=1:n_unions
        A_id = curr_unions(i,1);
        A_mat = AUX_Edgelist2Adj(Networks_Unique{A_id});
        B_id = curr_unions(i,2);
        B_mat = AUX_Edgelist2Adj(Networks_Unique{B_id});
        [T_id, T_mat, Networks_Key, Networks_Unique, Networks_Measures] = ...
            MP_Network_Union(A_mat, B_mat, 1, Networks_Key, Networks_Unique, Networks_Measures);
        
        present = false;
        for k=1:length(network_pool)
            if network_pool(k) == T_id
                present=true;
                break
            end
        end
        if present == false
            network_pool = [network_pool, T_id];
            layer_paths{curr_layer}{i} = [layer_paths{curr_layer}{i}, T_id];
        else
            layer_paths{curr_layer}{i} = [];
        end
        % Join networks
        % Include in unions: key=T_id, value={..., [A_id, B_id]}

        unions = [unions; T_id, A_id, B_id, curr_layer];

    end

    empty_idx = cellfun(@isempty, layer_paths{curr_layer});
    layer_paths{curr_layer}(empty_idx) = [];
    layer_unions{curr_layer}(empty_idx, :) = [];

    disp('Saving data')
    tic
    save(layer_path, 'network_pool', 'curr_layer', 'layer_unions', ...
        'layer_paths', 'unions', 'partitions')

    save(metadata_path, 'Networks_Key', 'Networks_Unique', ...
        'Networks_Measures')
    toc
    % Save data for each loop
end

partitions = array2table(partitions, 'VariableNames', {'NRed','Prod','Layer'});
unions = array2table(unions, 'VariableNames', {'NRed','R1','R2','Layer'});

writetable(partitions, '../../data/partition_metadata.csv')
writetable(unions, '../../data/union_metadata.csv')
