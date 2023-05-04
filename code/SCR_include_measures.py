import os
import pandas as pd

data_path = 'data/Networld_N200_TMax10000/'

betas = [10]

measures = pd.read_csv('data/metadata_measures.csv')
### This in case the column isnt already included in the file, but id rather
### do it just once...
# measures.reset_index(names='NRed', inplace=True)
# measures['NRed'] = measures['NRed'] + 1
# measures.to_csv('data/metadata_measures.csv', index=False)

for beta in betas:
    print(f'Processing Beta = {beta}')
    file_name = f'ABD_N200_K5_Beta{beta}.csv'
    ab_table = pd.read_csv(data_path + file_name)
    ab_table = ab_table.merge(measures, on='NRed')
    out_name = f'ABD_MEA_N200_K5_Beta{beta}.csv'
    ab_table.to_csv(data_path + out_name, index=False)
