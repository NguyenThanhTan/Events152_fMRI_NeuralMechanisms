# Purpose
## Preprocessing

This repository contains the source code to preprocess fMRI data from people watching everyday activities (4 of them). The preprocessing pipeline is based on fMRIprep/xcpEngine.

fMRIprep parcel-average BOLD timeseries are saved at: `voxelwiseAnalyses/np2/`  \
xcpEngine parcel-average BOLD timeseries are saved at: `voxelwiseAnalyses/XCP_OUTPUT*`

### Validation
#### Rationale
To validate that the preprocessing pipeline is working and the data quality is good, we correlate the parcel-average BOLD timeseries with visual features of the activities that participants saw during the fMRI scan. In particular, the following visual features are used: 1) pixel change mean, 2) pixel change variance, 3) luminance mean, 4) luminance variance. We expect that 1) the BOLD timeseries of parcels in the visual cortex should correlate highly with these visual features, and 2) the variability of correlations across participants should be low (because these visual features are low-level and should elicit similar responses across participants) and across activities should be low (because these visual features are low-level and should be similar across activities).

#### Method
##### Prepare Visual Features
4 activities in voxelwiseAnalyses/knitr_tan/median_correlation_with_shifts/movies/*.mp4 are used. The visual features are extracted using `voxelwiseAnalyses/knitr_tan/median_correlation_with_shifts/extract_visual_features.ipynb`. Timeseries of visual features are saved at: `voxelwiseAnalyses/knitr_tan/median_correlation_with_shifts/movie_visual_stats/*.csv`. Because the BOLD timeseries and visual features have different sampling rates (1.483 second for BOLD, 1/30 second for visual features), we need to downsampled visual features. We use this script `voxelwiseAnalyses/knitr_tan/median_correlation_with_shifts/convo_visual_feature.m` to apply a hemodynamic response function to timeseries of visual features, the output will have the same sampling rate as BOLD timeseries. The output is saved at: `voxelwiseAnalyses/knitr_tan/median_correlation_with_shifts/out_convo_visual/*.csv`

##### Correlate BOLD timeseries with Visual Features
The script to correlate BOLD timeseries with visual features is at: `voxelwiseAnalyses/knitr_tan/median_correlation_with_shifts/Feature_Parcel_Correlations.rnw`. The correlation results are saved at: `voxelwiseAnalyses/knitr_tan/median_correlation_with_shifts/VisualCorrs_1_500/`

##### Results
To visualize correlations, we have different types of plots at: `voxelwiseAnalyses/knitr_tan/median_correlation_with_shifts/correlation_statistics.ipynb`. 

## Hypothesis Testing

Both confirmatory and exploratory purposes: confirmatory because we want to test the hypothesis that midline brain dopamine system monitor prediction error, and use it as a signal to trigger event updating; exploratory because there might be other signals triggering event updating (e.g. uncertainty) and we want to identify neural correlates underlying these signals. Analysis approach: build computational models embodying different triggering mechanisms, and correlate these triggering signals with neural activity in different brain regions.

### Prepare Segmentation Features
4 activities in voxelwiseAnalyses/knitr_tan/median_correlation_with_shifts/movies/*.mp4 are used. The segmentation features are extracted from SEM's output files (\*diagnostic_101.pkl) using `voxelwiseAnalyses/knitr_tan/median_correlation_with_shifts/extract_segmentation_features.ipynb`. Timeseries of segmentation features are saved at: `voxelwiseAnalyses/knitr_tan/median_correlation_with_shifts/movie_segmentation_stats/*.csv`. Because the BOLD timeseries and visual features have different sampling rates (1.483 second for BOLD, 1/3 second for segmentation features), we need to downsampled segmentation features. We use this script `voxelwiseAnalyses/knitr_tan/median_correlation_with_shifts/convo_segmentation_feature.m` to apply a hemodynamic response function to timeseries of visual features, the output will have the same sampling rate as BOLD timeseries. The output is saved at: `voxelwiseAnalyses/knitr_tan/median_correlation_with_shifts/out_convo_segmentation/*.csv`


# Data
## Data Collection

The were two-sessions for each participant. In session 1, participants watched 4 activities while being in the scanner. In session 2, participants are asked to free-recall, then perform Yes/No recognition task. Then, participants watched activities again twice and were asked to segment these activities into meaninggul events (one at fine-grain and one at coarse-grain level). 

## Data Organization

Behavioral segmentation data is at:
...

fMRI data in BIDS format is at *events152_BIDS*. The data is organized in the following way:
- *sub-01* is the first participant
  - *anat* contains anatomical data
  - *fmap* contains fieldmap data
  - *func* contains functional connectivity data

# Visualizations
## BOLD against Movement
`voxelwiseAnalyses/knitr_tan/median_correlation_with_shifts/compare_preprocessing_pipelines.ipynb` plots BOLD timeseries against movement parameters for each subject, for multiple preprocessing pipelines.
## Compare Different Preprocessing Pipelines
`voxelwiseAnalyses/knitr_tan/median_correlation_with_shifts/compare_preprocessing_pipelines.ipynb` plots the diagonal plots of correlations with pixel change mean to contrast two preprocessing pipelines.
## Distribution of Correlations
For each preprocessing pipeline and each visual or segmentation feature, we can calculate correlations between parcel-averaged BOLD timeseries and the feature for all participants. `voxelwiseAnalyses/knitr_tan/median_correlation_with_shifts/plot_correlation_distributions.ipynb` plots different types of distributions of correlations (e.g. within a network across parcels, across networks, etc.)