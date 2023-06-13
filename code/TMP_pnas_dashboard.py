### Modules ###

from dash import Dash, html, dcc
import plotly.express as px
import pandas as pd
import numpy as np
import os

from scipy.stats import entropy
from matlab_utils import *

### Data loading ###
os.chdir('/home/kiaran/Desktop/Ciencia_de_Datos/TFM/CAB_Complejidad/code/networld_matlab/')
base_path = '../../data/Networld_N40_TMax5000_Kinetics_Binomial_'

plot_data = {}
for k in ['20','10', '5', '1', '0.1', '0.01']:

    data_path = base_path + f'K{k}/'

    nt_list = []
    for data_file in os.listdir(data_path):
        info = data_file[:-4].split('_')
        if info[0] != 'SRC':
            continue
        beta = info[2][4:]
        rep = info[4][3:]
        data_file = data_path + data_file
        src = load_src_networld(data_file)
        src['beta'] = float(beta)
        src['rep'] = int(rep)
        nt_list.append(src)

    exp_data = pd.concat(nt_list, axis=0)
    exp_data = exp_data.sort_values(by=['beta', 'rep', 'NRed'])
    exp_data = exp_data.groupby(['beta', 'NRed'])['NRep'].sum().reset_index()
    exp_data['NRep'] = exp_data['NRep'] / \
        exp_data.groupby('beta')['NRep'].transform(sum)

    plot_dat = exp_data.groupby('beta')['NRed'].nunique().reset_index()
    plot_dat.rename(columns={'NRed': '# Configs'}, inplace=True)
    plot_dat['entropy'] = exp_data.groupby('beta')['NRep'].aggregate(entropy).reset_index(drop=True)
    plot_dat['entropy'] = plot_dat['entropy'] / np.log2(plot_dat['# Configs'])

    tmp_data = pd.concat(nt_list, axis=0)
    tmp_data = tmp_data.sort_values(by=['beta', 'rep', 'NRed'])
    tmp_data = tmp_data.groupby(['beta', 'rep', 't'])['NRep'].sum().reset_index()
    plot_dat['mean_num_nets'] = tmp_data.groupby(['beta'])['NRep'].mean().reset_index(drop=True)

    plot_data[k] = plot_dat

print('Finished Loading')

app = Dash(__name__)

app.layout = html.Div([
    dcc.Tabs([
        dcc.Tab(label='Linear beta', children=html.Div([
            html.Div([
                html.P(f'K = {k}'),
                dcc.Graph(
                    id = f'{k} - 2H - linear',
                    figure = px.scatter(plot_data[k], x='beta', y='# Configs',
                            log_x=False, log_y=True, range_x=[0,3],
                            title='2H', labels=dict(beta='β')),
                    style={'width': '33%', 'display': 'inline-block'}
                ),
                dcc.Graph(
                    id = f'{k} - 3H - linear',
                    figure = px.scatter(plot_data[k], x='beta', y='entropy',
                            log_x=False, log_y=False, range_x=[0,3],
                            title='3B', labels=dict(beta='β', entropy='Norm H')),
                    style={'width': '33%', 'display': 'inline-block'}
                ),
                dcc.Graph(
                    id = f'{k} - mean_number - linear',
                    figure = px.scatter(plot_data[k], x='beta', y='mean_num_nets',
                            log_x=False, log_y=False, range_x=[0,3],
                            title='Número medio redes', labels=dict(beta='β', mean_num_nets='Mean N(R)')),
                    style={'width': '33%', 'display': 'inline-block'}
                )
            ])
        for k in ['20','10','5', '1', '0.1', '0.01']])),
        dcc.Tab(label='Log beta', children=html.Div([
            html.Div([
                html.P(f'K = {k}'),
                dcc.Graph(
                    id = f'{k} - 2H - log',
                    figure = px.scatter(plot_data[k], x='beta', y='# Configs',
                            log_x=True, log_y=True,
                            title='2H', labels=dict(beta='β')),
                    style={'width': '33%', 'display': 'inline-block'}
                ),
                dcc.Graph(
                    id = f'{k} - 3H - log',
                    figure = px.scatter(plot_data[k], x='beta', y='entropy',
                            log_x=True, log_y=False,
                            title='3B', labels=dict(beta='β', entropy='Norm H')),
                    style={'width': '33%', 'display': 'inline-block'}
                ),
                dcc.Graph(
                    id = f'{k} - mean_number - log',
                    figure = px.scatter(plot_data[k], x='beta', y='mean_num_nets',
                            log_x=True, log_y=False,
                            title='Número medio redes', labels=dict(beta='β', mean_num_nets='Mean N(R)')),
                    style={'width': '33%', 'display': 'inline-block'}
                )
            ])
        for k in ['20','10','5', '1', '0.1', '0.01']]))
    ])
])

if __name__ == '__main__':
    app.run_server(debug=True)