from scipy.io import loadmat
#from mat73 import loadmat
import os
import numpy as np
import pandas as pd

def load_raw_networld(
    path: str
) -> list:
    """
    Loads a RAW Networld mat file and formats it as a list (for each time point) of lists (for each network) of networks.
    """
    networks = loadmat(path)
    networks = networks['Networks'][0]
    networks = networks.tolist()
    networks = [L[0].tolist() for L in networks]
    return networks

def load_src_networld(
    path: str
) -> pd.DataFrame:
    """
    Loads an SRC Networld mat file and formats it as dataframe.
    """
    mat = loadmat(path)
    nt = pd.DataFrame(mat['Networks_Time'], columns=['t','NRed','NRep'])
    nt['NRed'] -= 1
    nt = nt.groupby(['t','NRed'])['NRep'].sum().reset_index()
    return nt

def load_meta_networld(
        path: str = "/home/kiaran/Desktop/Ciencia_de_Datos/TFM/CAB_Complejidad/data/networld_metadata.mat"
) -> dict:
    """
    Loads global networld metadata.
    """
    metadata = {}
    mat = loadmat(path)
    networks = mat['Networks_Unique'][0].tolist()
    measures = pd.DataFrame(mat['Networks_Measures'],
                                        columns=['N', 'Lamb1', 'Lamb2', 'mu', 'GrMedio', 'H'])
    measures['NRed'] = mat['Networks_Key'][0] - 1
    return networks, measures

def compute_abundance(
        nt_list: list(pd.DataFrame)
) -> pd.DataFrame:
    """
    Computes abundances from a a list of Network_Times table.

    The list should correspond to the tables for several repetitions.
    """
    nt_data = pd.concat(nt_list)
    ab_data = nt_data.groupby('NRed')['NRep'].sum().reset_index()
    ab_data['NRep'] = ab_data['NRep'] / ab_data['NRep'].sum()
    ab_data.rename(columns={'NRep':'Ab'}, inplace=True)
    return ab_data
