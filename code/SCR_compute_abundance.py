import os
import pandas as pd

from networld_utils import *

data_path = 'data/Networld_N200_TMax10000/'

betas = [0.001,0.0015849,0.0025119,0.0039811,0.0063096,
         0.01,0.015849,0.025119,0.039811,0.063096,
         0.1,0.15849,0.25119,0.39811,0.63096,
         1, 1.5849, 2.5119, 3.9811, 6.3096, 10]

conv_time = 2000

#measures = pd.read_csv('data/metadata_measures.csv')

for beta in betas:
    print(f'Processing Beta = {beta}')
    nt_data = [pd.read_csv(data_path + file) 
                for file in os.listdir(data_path) 
                if (f'Beta{beta}_' in file) and ('SRC' in file)]
    nt_data = [nt.loc[nt['t'] >= conv_time] for nt in nt_data]
    ab_table = compute_abundance(nt_data)

    #ab_table = ab_table.merge(measures, on='NRed', how='right')
    #ab_table = ab_table.fillna(0)

    ab_table['beta'] = beta
    
    out_name = f'ABD_N200_K5_Beta{beta}.csv'
    ab_table.to_csv(data_path + out_name, index=False)


