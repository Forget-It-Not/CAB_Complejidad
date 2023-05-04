import os
import pandas as pd

from networld_utils import *

data_path = 'data/Networld_N200_TMax10000/'

betas = [10]

conv_time = 2000

for beta in betas:
    print(f'Processing Beta = {beta}')
    nt_data = [pd.read_csv(data_path + file) 
               for file in os.listdir(data_path) 
               if (f'Beta{beta}_' in file) and ('SRC' in file)]
    nt_data = [nt.loc[nt['t'] >= conv_time] for nt in nt_data]
    ab_table = compute_abundance(nt_data)
    ab_table['beta'] = beta
    
    out_name = f'ABD_N200_K5_Beta{beta}.csv'
    ab_table.to_csv(data_path + out_name, index=False)

#TODO: que las abundancias incluyan también las redes no presentes, 
#pero a poder ser después de empezar el análisis exploratorio

