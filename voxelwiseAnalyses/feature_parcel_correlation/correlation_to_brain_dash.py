import json
import os
from dash import Dash, dcc, html, dash_table, callback
from dash.dependencies import Input, Output
import plotly.express as px
import pandas as pd
import numpy as np
import cv2

root_dir = "/data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/voxelwiseAnalyses/"

# Sample data
# df_sch = pd.read_table(os.path.join(correlation_dir, "xcp_24p_gsrCorrs_uncertainty_run4_sch.txt"), sep=" ")
# df_subcortical = pd.read_table(os.path.join(correlation_dir, "xcp_24p_gsrCorrs_uncertainty_run4_subcortical.txt"), sep=" ")

# Read real data
## Load correlation data between a feature (visual stats or pe) and parcel-average time series

# copied from Feature_Parcel_Correlations.rnw
run_ids = ["1.2.3", "6.3.9", "3.1.3", "2.4.1"]


feature_names = ["pe", "uncertainty", "sem", "coarse", "fine"]
# feature_names = ["pe", "uncertainty"]
# preprocess_tags = ["xcp_24p"]
preprocess_tags = ["xcp_24p_gsr", "xcp_24p"]

df_sch = pd.DataFrame()
df_subcortical = pd.DataFrame()
for feature_name in feature_names:
    for preprocess_tag in preprocess_tags:
        correlation_dir = os.path.join(root_dir, f"feature_parcel_correlation/seg_{preprocess_tag}_corrs_1_550")
        for i, r in enumerate(run_ids):
            if "xcp" in preprocess_tag:
                run_corr_sch = pd.read_table(f'{correlation_dir}/{preprocess_tag}Corrs_{feature_name}_run{i+1}_sch.txt', sep=' ',)
                run_corr_subcortical = pd.read_table(f'{correlation_dir}/{preprocess_tag}Corrs_{feature_name}_run{i+1}_subcortical.txt', sep=' ',)
            elif "np2" in preprocess_tag:
                run_corr_sch = pd.read_table(f'{correlation_dir}/np2Corrs_{feature_name}_run{i+1}_sch.txt', sep=' ',)
                run_corr_subcortical = pd.read_table(f'{correlation_dir}/np2Corrs_{feature_name}_run{i+1}_subcortical.txt', sep=' ',)
            run_corr_sch['run'] = r
            run_corr_subcortical['run'] = r
            run_corr_sch['feature_name'] = feature_name
            run_corr_subcortical['feature_name'] = feature_name
            run_corr_sch['img'] = 'sch' # Schaefer
            run_corr_subcortical['img'] = 'subcortical' # subcortical
            run_corr_sch['preprocess_tag'] = preprocess_tag
            run_corr_subcortical['preprocess_tag'] = preprocess_tag
            df_sch = pd.concat([df_sch, run_corr_sch])
            df_subcortical = pd.concat([df_subcortical, run_corr_subcortical])
ids = ['sub.id', 'run', 'img', 'preprocess_tag', 'feature_name']
df_sch_long = df_sch.melt(id_vars=ids, var_name='parcel', value_name='correlation')
df_subcortical_long = df_subcortical.melt(id_vars=ids, var_name='parcel', value_name='correlation')
df_sch_sub_long = pd.concat([df_sch_long, df_subcortical_long], axis=0)
sch_tian_np2_parcel = pd.read_csv(os.path.join(root_dir, "atlas/schaefer_tian_np2_parcel.csv"))
df_sch_sub_long = pd.merge(df_sch_sub_long, sch_tian_np2_parcel, on='parcel', how='left')
  
# Initialize the app
app = Dash(__name__)

# App layout
print(f"all networks: {list(df_sch_sub_long.network.unique())}")
app.layout = html.Div([
    html.Div(children='Correlation Between PE and BOLD', id="title"),
    # html.Hr(),
    dcc.Dropdown(options=list(df_sch_sub_long.feature_name.unique()), value=list(df_sch_sub_long.feature_name.unique())[0], id='feature-dropdown'),
    dcc.Dropdown(options=list(df_sch_sub_long.network.unique()), value=list(df_sch_sub_long.network.unique())[0], id='network-dropdown'),
    dcc.Dropdown(options=list(df_sch_sub_long.preprocess_tag.unique()), value=list(df_sch_sub_long.preprocess_tag.unique())[0], id='preprocess-dropdown'),
    # dash_table.DataTable(data=df.to_dict('records'), page_size=6),
    dcc.Graph(
        id='correlation-plot',
        figure={}
    ),
    dcc.Graph(figure={}, id='brain-plot')
])
# Add controls to choose type of movie feature to correlate
@callback(
    Output(component_id='title', component_property='children'),
    Input(component_id='feature-dropdown', component_property='value')
)
def update_title(col_chosen):
    return f'Correlation Between {col_chosen} and BOLD'
# Add controls to plot correlations of parcels for selected network
@callback(
    Output(component_id='correlation-plot', component_property='figure'),
    Input(component_id='network-dropdown', component_property='value'),
    Input(component_id='feature-dropdown', component_property='value'),
    Input(component_id='preprocess-dropdown', component_property='value')
)
def update_correlation_plot(network, feature_name, preprocess_tag):
    fig = px.box(df_sch_sub_long[(df_sch_sub_long.network == network) & (df_sch_sub_long.feature_name == feature_name) & (df_sch_sub_long.preprocess_tag == preprocess_tag)], x="parcel", y="correlation")
    # fig.update_layout(clickmode='event+select')
    # set y-axis range
    fig.update_yaxes(range=[-0.5, 0.5])
    fig.update_layout(width=min(1200, 40 * len(df_sch_sub_long[df_sch_sub_long.network == network].parcel.unique())))
    fig.update_traces(marker_size=10)
    return fig

# Add controls to plot brain image for selected parcel
@callback(
    Output(component_id='brain-plot', component_property='figure'),
    Input(component_id='correlation-plot', component_property='clickData')
)
def update_brain_image(col_chosen):
    # print(col_chosen)
    if col_chosen is None:
        p_id = "LH_Vis_1"
    else:
        p_id = col_chosen['points'][0]['x']
    # read a jpg image
    image = cv2.imread(os.path.join(root_dir, f"parcel_images/Schaefer400x7_TianSubcortexS2x3T/{p_id}.jpg"))
    fig = px.imshow(image)
    return fig

# Run the app
if __name__ == '__main__':
    app.run_server(debug=True)

