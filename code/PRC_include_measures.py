import os
import pandas as pd

data_path = 'data/Networld_N200_TMax10000/'

betas = [0.001,0.0015849,0.0025119,0.0039811,0.0063096,
         0.01,0.015849,0.025119,0.039811,0.063096,
         0.1,0.15849,0.25119,0.39811,0.63096,
         1, 1.5849, 2.5119, 3.9811, 6.3096]

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
