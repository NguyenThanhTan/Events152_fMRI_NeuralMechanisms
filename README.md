# Purpose
## Preprocessing

This repository contains the source code to preprocess fMRI data from people watching everyday activities (4 of them). The preprocessing pipeline is based on fMRIprep/xcpEngine.

fMRIprep parcel-average BOLD signals are saved at: `voxelwiseAnalyses/np2/`  \
xcpEngine parcel-average BOLD signals are saved at: `voxelwiseAnalyses/XCP_OUTPUT*`

### Validation
#### Rationale
To validate that the preprocessing pipeline is working and the data quality is good, we correlate the parcel-average BOLD signals with visual features of the activities that participants saw during the fMRI scan. In particular, the following visual features are used: 1) pixel change mean, 2) pixel change variance, 3) luminance mean, 4) luminance variance. We expect that 1) the BOLD signals of parcels in the visual cortex should correlate highly with these visual features, and 2) the variability of correlations across participants should be low (because these visual features are low-level and should elicit similar responses across participants) and across activities should be low (because these visual features are low-level and should be similar across activities).

#### Method
##### Prepare Visual Features
4 activities in voxelwiseAnalyses/knitr_tan/median_correlation_with_shifts/movies/*.mp4 are used. The visual features are extracted using `voxelwiseAnalyses/knitr_tan/median_correlation_with_shifts/extract_visual_features.ipynb`. Timeseries of visual features are saved at: `voxelwiseAnalyses/knitr_tan/median_correlation_with_shifts/movie_visual_stats/*.csv`. Because the BOLD signals and visual features have different sampling rates (1.483 second for BOLD, 1/30 second for visual features), we need to downsampled visual features. We use this script `voxelwiseAnalyses/knitr_tan/median_correlation_with_shifts/doResample.m` to apply a hemodynamic response function to timeseries of visual features, the output will have the same sampling rate as BOLD signals. The output is saved at: `voxelwiseAnalyses/knitr_tan/median_correlation_with_shifts/out_convo_visual/*.csv`

##### Correlate BOLD Signals with Visual Features
The script to correlate BOLD signals with visual features is at: `/data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/voxelwiseAnalyses/knitr_tan/median_correlation_with_shifts/Feature_Parcel_Correlations.rnw`. The correlation results are saved at: `voxelwiseAnalyses/knitr_tan/median_correlation_with_shifts/VisualCorrs_1_500/`

##### Results
To visualize correlations, we have different types of plots at: `voxelwiseAnalyses/knitr_tan/median_correlation_with_shifts/correlation_statistics.ipynb`. 

## Hypothesis Testing

The data is used for both confirmatory and exploratory purpose: confirmatory because we want to test the hypothesis that midline brain dopamine systems monitor prediction error, and use it as a signal to trigger event updating; exploratory because there might be other signals triggering event updating (e.g. uncertainty) and we want to identify neural correlates underlying these signals. Analysis approach: build computational models embodying different triggering mechanisms, and correlate these triggering signals with neural activity in different brain regions.

# Data
## Data Collection

The were two-sessions for each participant. In session 1, participants watched 4 activities while being in the scanner. In session 2, participants watched them again twice and were asked to segment these activities into meaninggul events (one at fine-grain and one at coarse-grain level). 

## Data Organization

Behavioral segmentation data is at:
...

fMRI data in BIDS format is at *events152_BIDS*. The data is organized in the following way:
- *sub-01* is the first participant
  - *anat* contains anatomical data
  - *fmap* contains fieldmap data
  - *func* contains functional connectivity data