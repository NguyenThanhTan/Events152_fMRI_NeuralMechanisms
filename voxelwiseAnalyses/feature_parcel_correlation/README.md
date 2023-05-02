Specifically how files in this directory are used for hypothesis testing is described in the master README.md. This README is a technical supplementary 

# Correlate parcel-average BOLD with visual/segmentation signals

`voxelwiseAnalyses/feature_parcel_correlation/Feature_Parcel_Correlations.rnw` is designed such as you can correlate any type of feature (pixel change mean, prediction error, uncertainty, etc.) with any type of BOLD signals (xcp_24p_gsr or np2 or xcp_24p). It will save correlations and plot them on brain slices. \

After you knitr this file, the pdf name will be `voxelwiseAnalyses/feature_parcel_correlation/Feature_Parcel_Correlations.pdf`. Depending on the configurations you use while running it, you might want to change the pdf file name to reflect the configuration. \

# Visualization

`voxelwiseAnalyses/feature_parcel_correlation/plot_correlation_distributions.ipynb` is designed to group those correlations in multiple ways and plot them. \

`voxelwiseAnalyses/feature_parcel_correlation/correlation_to_brain_dash.py` is designed to group those correlations, plot them, and you can interact with the correlations to visualize the brain parcel. This is helpful to map these plots (can represent statistics better) onto brain slices.