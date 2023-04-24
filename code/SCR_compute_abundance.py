import os
import pandas as pd

from networld_utils import *

data_path = ''

ab_data = []
for beta in [0.1,1]:
    nt_data = [pd.read_csv(data_path + file) 
               for file in os.listdir(data_path) if f'Beta{beta}_' in file]
    ab_table = compute_abundance(nt_data)
    ab_table['beta'] = beta
    ab_data.append(ab_table)

ab_data = pd.concat(ab_data)

out_name = ''
ab_data.to_csv(data_path + out_name)

    