from scipy.io import loadmat
import numpy as np
import pandas as pd

def load_raw_networld(
    path: str
) -> list:
    """
    Loads a raw Networld mat file and formats it as a list (for each time point) of lists (for each network) of networks.
    """
    networks = loadmat(path)
    networks = networks['Networks'][0]
    networks = networks.tolist()
    networks = [L[0].tolist() for L in networks]
    return networks

def load_processed_networld(
    path: str
) -> None:
    """
    Loads a processed Networld mat file and
    """
    mat = loadmat(path)
    output = {}
    name = path.split('/')[-1]
    info = name.split('_')
    output['Beta'] = info[1][4:]
    output['N'] = info[0][1:]
    output['T_Max'] = info[2][4:]
    output['Networks_Unique'] = mat['Networks_Unique'][0].tolist()
    output['Networks_Measures'] = pd.DataFrame(mat['Networks_Measures'], columns = ['N', 'Lamb1', 'Lamb2', 'mu', 'GrMedio', 'H'])
    output['Networks_Time'] = pd.DataFrame(mat['Networks_Time'], columns = ['t', 'NRed', 'NRep'])
    output['Networks_Time']['NRed'] -= 1

    output['Networks_Measures'] = output['Networks_Measures'].reset_index(names='NRed')
    output['Networks_Time'] = output['Networks_Time'].groupby(['t','NRed']).sum().reset_index()
    return output