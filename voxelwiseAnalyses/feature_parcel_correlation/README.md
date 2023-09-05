Specifically how files in this directory are used for hypothesis testing is described in the master README.md. This README is a technical supplementary 

#### Prepare segmentation signals
4 activities in `voxelwiseAnalyses/knitr/movie_features/movies/*.mp4` are used. The segmentation signals are extracted from SEM's output files at `voxelwiseAnalyses/movie_features/movie_segmentation_stats/*_diagnostic_101.pkl` using `voxelwiseAnalyses/movie_features/extract_segmentation_features.ipynb`. Timeseries of segmentation signals are saved at: `voxelwiseAnalyses/movie_features/movie_segmentation_stats/*.csv`. Because the BOLD timeseries and segmentation signals, prediction error and prediction uncertainty, have different sampling rates (1.483 second for BOLD, 1/3 second for segmentation signals), we need to downsampled segmentation signals. We use this script `voxelwiseAnalyses/movie_features/convo_segmentation_feature.m` to apply a hemodynamic response function (HRF) to timeseries of segmentation signals, the output will have the same sampling rate as BOLD timeseries. The output is saved at: `voxelwiseAnalyses/movie_features/out_convo_segmentation/*.csv`

# Correlate parcel-average BOLD with visual/segmentation signals

`voxelwiseAnalyses/feature_parcel_correlation/Feature_Parcel_Correlations.rnw` is designed such as you can correlate any type of feature (pixel change mean, prediction error, uncertainty, etc.) with any type of BOLD signals (xcp_24p_gsr or np2 or xcp_24p). It will save correlations and plot them on brain slices. \
After you knitr this file, the pdf name will be `voxelwiseAnalyses/feature_parcel_correlation/Feature_Parcel_Correlations.pdf`. Depending on the configurations you use while running it, you might want to change the pdf file name to reflect the configuration (e.g. `voxelwiseAnalyses/feature_parcel_correlation/Feature_Parcel_Correlations_pcm_xcp_24p_gsr.pdf` where pixel change mean is correlated with parcel timeseries from xcp_24p_gsr config). 

# Visualization

`voxelwiseAnalyses/feature_parcel_correlation/plot_correlation_distributions.ipynb` is designed to group those correlations in multiple ways and plot them. \
`voxelwiseAnalyses/feature_parcel_correlation/correlation_to_brain_dash.py` is designed to group those correlations, plot them, and you can interact with the correlations to visualize the brain parcel. This is helpful to map these plots (can represent statistics better) onto brain slices.