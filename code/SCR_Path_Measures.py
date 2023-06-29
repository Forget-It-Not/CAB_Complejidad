import numpy as np
import pandas as pd

# Partition and Union metadata
partitions = pd.read_csv('../data/partition_metadata.csv')
partitions['Layer'] -= 1
unions = pd.read_csv('../data/union_metadata.csv')
unions['Layer'] -= 1

# Set of networks generated
networks = list(set(partitions['Prod']).union(set(unions['NRed'])))
path_data = pd.DataFrame({'NRed': networks})

# Number of partition reactions that generate a network
num_partitions = partitions.groupby('Prod').size().reset_index()
num_partitions.rename(columns={'Prod':'NRed',0:'NPart'}, inplace=True)
path_data = path_data.merge(num_partitions, on='NRed', how='left')

# Number of union reactions that generate a network
num_unions = unions.groupby('NRed').size().reset_index()
num_unions.rename(columns={0:'NUnion'}, inplace=True)
path_data = path_data.merge(num_unions, on='NRed', how='left')

# Total number of reactions that generate a network
path_data.fillna(0, inplace=True)
path_data['NReact'] = path_data['NPart'] + path_data['NUnion']

# Length of the shortest partition path (shortest path that generates the network
# by degradation)

# Corresponds to the minimum layer in which a generating partition was found
lgd_partitions = partitions.groupby('Prod')['Layer'].min().reset_index()
lgd_partitions.rename(columns={'Prod':'NRed','Layer':'L(SP_Part)'}, inplace=True)
path_data = path_data.merge(lgd_partitions, on='NRed', how='left')

# Length of the shortest union path (shortest path that generates the network 
# by union)

# Corresponds to the minimum layer in which a generating union was found
lgd_unions = unions.groupby('NRed')['Layer'].min().reset_index()
lgd_unions.rename(columns={'Layer':'L(SP_Union)'}, inplace=True)
lgd_unions.loc[lgd_unions['NRed']==1, 'L(SP_Union)'] = 0
path_data = path_data.merge(lgd_unions, on='NRed', how='left')

# Length of the shortest path
path_data.fillna(np.inf, inplace=True)
path_data['L(SP_D)'] = path_data[['L(SP_Part)','L(SP_Union)']].min(axis=1)

# Length of shortest path and number of paths without degradation reactions
df = {'NRed':[1], 'L(SP_U)':[0], 'NP_U': [1]}
layer = 1

while True:
    # Reenact the growth process following only union reactions that include
    # the networks that have appeared (discard those arising from degradation)
    unions_layer = unions.loc[unions['Layer']==layer]
    if len(unions_layer) == 0:
        break

    unions_layer = unions_layer.loc[(unions_layer['R1'].isin(df['NRed'])) &
                                    (unions_layer['R2'].isin(df['NRed']))]
    for i, row in unions_layer.iterrows():
        nred = row['NRed']
        R1_npath = df['NPaths'][df['NRed'].index(row['R1'])]
        R2_npath = df['NPaths'][df['NRed'].index(row['R2'])]
        # Since the process can only go forward, the nº of paths is the sum over
        # all reactions of the product of the nº of paths of each reactive
        react_npaths = R1_npath * R2_npath
        # The first time the network is found, the layer is the minimum length
        if nred not in df['NRed']:
            df['NRed'].append(nred)
            df['L(GU)'].append(layer)
            df['NPaths'].append(react_npaths)
        else:
            idx = df['NRed'].index(nred)
            df['NPaths'][idx] += react_npaths

    layer += 1

df = pd.DataFrame(df)
path_data = path_data.merge(df, on='NRed', how='left')
path_data.fillna(np.inf, inplace=True)

# Number of paths with degradation reactions

# Version 1: path defined as the sequence of reactions involved, even if they
# happen multiple times

part_dict = {k:list(table['Prod']) for k, table in partitions.groupby('NRed')}
union_dict = {k:int(table['NRed']) for k, table in unions.groupby(['R1','R2'])}

curr_layer = 1
npaths = {0:{1:1}}
gen_networks = {1}

while curr_layer < 6:
    print(curr_layer)
    npaths[curr_layer] = {}
    new_gen_networks = set()
    for head in npaths[curr_layer-1].keys():
        for part_prod in part_dict[head]:
            if part_prod not in npaths[curr_layer].keys():
                npaths[curr_layer][part_prod] = npaths[curr_layer-1][head]
            else:
                npaths[curr_layer][part_prod] += npaths[curr_layer-1][head]
            new_gen_networks.add(part_prod)

        for other in gen_networks:
            try:
                product = union_dict[(head,other)]
            except:
                continue
            new_gen_networks.add(product)
            if head == other:
                for i in range(0, -(-curr_layer//2)):
                    if product not in npaths[curr_layer].keys():
                        try:
                            npaths[curr_layer][product] = npaths[i][head]*npaths[curr_layer-1-i][other]
                        except:
                            pass
                    else:
                        try:
                            npaths[curr_layer][product] += npaths[i][head]*npaths[curr_layer-1-i][other]
                        except:
                            pass
            else:
                for i in range(0, curr_layer):
                    if product not in npaths[curr_layer].keys():
                        try:
                            npaths[curr_layer][product] = npaths[i][head]*npaths[curr_layer-1-i][other]
                        except:
                            pass
                    else:
                        try:
                            npaths[curr_layer][product] += npaths[i][head]*npaths[curr_layer-1-i][other]
                        except:
                            pass
    
    curr_layer += 1
    gen_networks = new_gen_networks

gen_networks = list(gen_networks)
num_paths = []
for net in gen_networks:
    number_paths = 0
    for nums in npaths.values():
        try:
            number_paths += nums[net]
        except:
            continue
    num_paths.append(number_paths)

df = pd.DataFrame({'NRed':gen_networks, 'NP_D_rseq': num_paths})
path_data = path_data.merge(df, on='NRed', how='left')
path_data.fillna(0, inplace=True)

# Version 2: path defined as the set of reactions involved, without repetitions

class Path:

    def __init__(self, reacts, tail):
        self.reacts = reacts
        self.tail = tail

    def __repr__(self):
        return repr(self.reacts) + " // " + str(self.tail)
    
unions.reset_index(names='NReact', inplace=True)
nunions = len(unions)
partitions.reset_index(names='NReact', inplace=True)
partitions['NReact'] += nunions

curr_layer = 1
layer_paths = {0:[Path({1:-1}, 1)]}

while True:

    empty_reacts = True

    for i, path in enumerate(layer_paths[curr_layer-1]):
        tail = path.tail
        tail_parts = partitions.loc[partitions['NRed']==tail]
        if len(tail_parts) > 0:
            empty_reacts = False
            for _, row in tail_parts.iterrows():
                if row['Prod'] not in path.reacts.keys():
                    new_reacts = path.reacts.copy()
                    new_reacts[row['Prod']] = row['NReact']
                    new_path = Path(new_reacts, row['Prod'])
                    if curr_layer not in layer_paths.keys():
                        layer_paths[curr_layer] = []
                    layer_paths[curr_layer].append(new_path)
        
        for pre_layer in range(curr_layer-1):
            for pre_path in layer_paths[pre_layer]:
                shared_nets = set(path.reacts.keys()) & set(pre_path.reacts.keys())
                flag = all([path.reacts[net] == pre_path.reacts[net] for net in shared_nets])
                if not flag:
                    continue
                pre_tail = pre_path.tail
                pre_union = unions.loc[((unions['R1'] == tail) & 
                                        (unions['R2'] == pre_tail)) |
                                       ((unions['R2'] == tail) & 
                                        (unions['R1'] == pre_tail))]
                if len(pre_union) > 0:
                    empty_reacts = False
                    pre_union = pre_union.iloc[0]
                else:
                    continue
                
                if (pre_union['NRed'] not in path.reacts.keys() and
                    pre_union['NRed'] not in pre_path.reacts.keys()):
                    new_reacts = dict( set(path.reacts.items()) | 
                                       set(pre_path.reacts.items()) )
                    new_reacts[pre_union['NRed']] = pre_union['NReact']
                    new_path = Path(new_reacts, pre_union['NRed'])
                    layer = len(new_path.reacts)-1
                    if layer not in layer_paths.keys():
                        layer_paths[layer] = []
                    layer_paths[layer].append(new_path)
        
        self_union = unions.loc[(unions['R1']==tail) & (unions['R2']==tail)]
        if len(self_union) > 0:
            empty_reacts = False
            self_union = self_union.iloc[0]
            new_reacts = path.reacts.copy()
            new_reacts[self_union['NRed']] = self_union['NReact']
            new_path = Path(new_reacts, self_union['NRed'])
            layer = len(new_path.reacts)-1
            if layer not in layer_paths.keys():
                layer_paths[layer] = []
            layer_paths[layer].append(new_path)

        for j in range(i):
            other_path = layer_paths[curr_layer-1][j]
            shared_nets = set(path.reacts.keys()) & set(other_path.reacts.keys())
            flag = all([path.reacts[net] == other_path.reacts[net] for net in shared_nets])
            if not flag:
                continue
            other_tail = other_path.tail
            other_union = unions.loc[((unions['R1'] == tail) & 
                                      (unions['R2'] == other_tail)) |
                                     ((unions['R2'] == tail) & 
                                      (unions['R1'] == other_tail))]
            if len(other_union) > 0:
                empty_reacts = False
                other_union = other_union.iloc[0]
            else:
                continue

            if (other_union['NRed'] not in path.reacts.keys() and
                other_union['NRed'] not in other_path.reacts.keys()):
                new_reacts = dict( set(path.reacts.items()) | 
                                   set(other_path.reacts.items()) )
                new_reacts[other_union['NRed']] = other_union['NReact']
                new_path = Path(new_reacts, other_union['NRed'])
                layer = len(new_path.reacts)-1
                if layer not in layer_paths.keys():
                    layer_paths[layer] = []
                layer_paths[layer].append(new_path)

    curr_layer += 1

    if empty_reacts:
        break

num_paths = {}
for paths in layer_paths.values():
    for path in paths:
        tail = path.tail
        if tail not in num_paths.keys():
            num_paths[tail] = 0
        num_paths[tail] += 1

df = pd.DataFrame({'NRed':num_paths.keys(), 'NP_D_rset':num_paths.values()})
path_data = path_data.merge(df, on='NRed', how='left')
path_data.fillna(0, inplace=True)