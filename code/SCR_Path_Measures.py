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

# Length of the partition geodesic (minimal path that generates the network
# by degradation)
lgd_partitions = partitions.groupby('Prod')['Layer'].min().reset_index()
lgd_partitions.rename(columns={'Prod':'NRed','Layer':'L(GPart)'}, inplace=True)
path_data = path_data.merge(lgd_partitions, on='NRed', how='left')

# Length of the union geodesic (minimal path that generates the network 
# by union)
lgd_unions = unions.groupby('NRed')['Layer'].min().reset_index()
lgd_unions.rename(columns={'Layer':'L(GUnion)'}, inplace=True)
lgd_unions.loc[lgd_unions['NRed']==1, 'L(GUnion)'] = 0
path_data = path_data.merge(lgd_unions, on='NRed', how='left')

# Length of the geodesic path
path_data.fillna(np.inf, inplace=True)
path_data['L(GD)'] = path_data[['L(GPart)','L(GUnion)']].min(axis=1)

# Length of geodesic and number of paths without degradation reactions
df = {'NRed':[1], 'L(GU)':[0], 'NPaths': [1]}
layer = 1

while True:
    unions_layer = unions.loc[unions['Layer']==layer]
    if len(unions_layer) == 0:
        break

    unions_layer = unions_layer.loc[(unions_layer['R1'].isin(df['NRed'])) &
                                    (unions_layer['R2'].isin(df['NRed']))]
    for i, row in unions_layer.iterrows():
        nred = row['NRed']
        R1_npath = df['NPaths'][df['NRed'].index(row['R1'])]
        R2_npath = df['NPaths'][df['NRed'].index(row['R2'])]
        react_npaths = R1_npath * R2_npath
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