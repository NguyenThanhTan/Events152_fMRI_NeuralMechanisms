# Data
## Data Collection

The were two-sessions for each participant. In session 1, participants watched 4 activities while being in the scanner. In session 2, participants are asked to free-recall, then perform Yes/No recognition task. Then, participants watched activities again twice and were asked to segment these activities into meaninggul events (one at fine-grain and one at coarse-grain level). 

## fMRI data
### fMRIprep Voxel BOLD Timeseries
fMRIprep voxel BOLD timeseries are saved at: `fmriprep/fmriprep/`  \
### XCP Parcel-Average BOLD Timeseries
The pipeline is based on fMRIprep/xcpEngine to process fmriprep's output.
To run XCP on each subject, go to `voxelwiseAnalyses/parcel_timeseries/XCP_24p_gsr_commands.sh` and the commands (each for each subject). On Penfield, you can run ~6 people at the same time without burning the server (it'll crash and XCP's output will contain errors). \
xcpEngine parcel-average BOLD timeseries are saved at: `voxelwiseAnalyses/parcel_timeseries/{xcp_config}XCP_OUTPUT*`
### NP2 Parcel-Average BOLD Timeseries
NP2 processes fMRIprep's output minimally (e.g. without global motion regression, etc.). NP2 timeseries are saved at `voxelwiseAnalyses/parcel_timeseries/np2/`

### Data Quality Check
#### BOLD against Movement
`voxelwiseAnalyses/parcel_timeseries/compare_preprocessing_pipelines.ipynb` plots BOLD timeseries against movement parameters for each subject, for multiple preprocessing pipelines.
#### Rationale
To validate that the preprocessing pipelines (XCP with different designs, or NP2) are working and the data quality is good, we correlate the parcel-average BOLD timeseries with visual features of the activities that participants saw during the fMRI scan. In particular, the following visual features are used: 1) pixel change mean, 2) pixel change variance, 3) luminance mean, 4) luminance variance. We expect that 1) the BOLD timeseries of parcels in the visual cortex should correlate highly with these visual features, and 2) the variability of correlations across participants should be low (because these visual features are low-level and should elicit similar responses across participants) and across activities should be low (because these visual features are low-level and should be similar across activities).

#### Method
##### Prepare Visual Features
4 activities in voxelwiseAnalyses/knitr_tan/median_correlation_with_shifts/movies/*.mp4 are used. The visual features are extracted using `voxelwiseAnalyses/movie_features/extract_visual_features.ipynb`. Timeseries of visual features are saved at: `voxelwiseAnalyses/movie_features/movie_visual_stats/*.csv`. Because the BOLD timeseries and visual features have different sampling rates (1.483 second for BOLD, 1/30 second for visual features), we need to downsampled visual features. We use this script `voxelwiseAnalyses/movie_features/convo_visual_feature.m` to apply a hemodynamic response function to timeseries of visual features, the output will have the same sampling rate as BOLD timeseries. The output is saved at: `voxelwiseAnalyses/movie_features/out_convo_visual/*.csv`

##### Correlate BOLD timeseries with Visual Features
The script to correlate BOLD timeseries with visual features is at: `voxelwiseAnalyses/feature_parcel_correlation/Feature_Parcel_Correlations.rnw`. The correlation results are saved at: `/voxelwiseAnalyses/feature_parcel_correlation/pcm_xcp_24p_gsr_corrs_1_550` or `voxelwiseAnalyses/feature_parcel_correlation/pcm_np2_corrs_1_550` depending on which preprocessing output you decide to correlate with visual features (pcm = pixel change mean in this case). \

#### Visualize Results
In addition to saving correlations between parcels and visual features, the script `feature_parcel_correlation/Feature_Parcel_Correlations.rnw` can also plot these correlations on individual brain slices on the knitr pdf output at `feature_parcel_correlation/Feature_Parcel_Correlations.pdf`
To visualize distributions of correlations, we have different types of plots at: `voxelwiseAnalyses/feature_parcel_correlation/plot_correlation_distributions.ipynb`. (e.g. within a network across parcels, across networks, etc.)\
To compare different preprocessing pipelines' timeseries correlation with pixel change mean, `voxelwiseAnalyses/parcel_timeseries/compare_preprocessing_pipelines.ipynb` plots the diagonal plots of correlations with pixel change mean to contrast two different preprocessing pipelines.


## Behavioral data
Participants came back for a second session, where they were asked to free-recall, then perform Yes/No recognition task. Then, participants watched activities again twice and were asked to segment these activities into meaninggul events (one at fine-grain and one at coarse-grain level; counter-balance). \
Raw data (from Psychopy) is at `data/`. \
Script to process raw data into free-recall and recognition is at: `Analysis/analyze_session_two.ipynb`. The result is saved at: `Analysis/memory_df.csv` \
Script to process raw data into segmentation data are at `Analysis/analyze_session_segmentation_only.py`. The result is saved at: `Analysis/segmentation.csv` \



## Hypothesis testing
### Brain regions tracking continuous segmentation signals
#### Methods
We treat the computational model (SEM) as an instrument, measuring prediction error and uncertainty that people experience in the 4 activities. We correlate SEM's prediction error and uncertainty with neural activity in different parcels. \
Confirmatory analysis: we want to test the hypothesis that midline brain dopamine system monitor prediction error, and use it as a signal to trigger event updating; \
Exploratory analysis: there might be other signals triggering event updating (e.g. uncertainty) and we want to identify neural correlates underlying these signals. \
For the comfirmatory analysis: We realized that we don't have the resolution to test the midline brain dopamine system. \ 
For the exploratory analysis, we need to correct for multiple comparisons. We use FDR to correct for multiple comparisons. \
Mike recommended using one of AFNI's tools that does FDR correction and also takes into account spatial autocorrelation. => TBC\
Jo found Neuroscout that seems to be relevant and used in a similar context. => TBC\

#### Prepare segmentation signals
4 activities in `voxelwiseAnalyses/knitr_tan/median_correlation_with_shifts/movies/*.mp4` are used. The segmentation signals are extracted from SEM's output files at `voxelwiseAnalyses/movie_features/movie_segmentation_stats/*_diagnostic_101.pkl` using `voxelwiseAnalyses/movie_features/extract_segmentation_features.ipynb`. Timeseries of segmentation signals are saved at: `voxelwiseAnalyses/movie_features/movie_segmentation_stats/*.csv`. Because the BOLD timeseries and segmentation signals, prediction error and prediction uncertainty, have different sampling rates (1.483 second for BOLD, 1/3 second for segmentation signals), we need to downsampled segmentation signals. We use this script `voxelwiseAnalyses/movie_features/convo_segmentation_feature.m` to apply a hemodynamic response function (HRF) to timeseries of segmentation signals, the output will have the same sampling rate as BOLD timeseries. The output is saved at: `voxelwiseAnalyses/movie_features/out_convo_segmentation/*.csv`

#### Correlate BOLD timeseries with segmentation signals
The script to correlate BOLD timeseries with segmentation signals is at: `voxelwiseAnalyses/feature_parcel_correlation/Feature_Parcel_Correlations.rnw`. The correlation results are saved at: `/voxelwiseAnalyses/feature_parcel_correlation/seg_xcp_24p_gsr_corrs_1_550` \

#### Visualize Results
Since segmentation signals such as prediction error or prediction uncertainty and visual signals such as pixel change mean have the same format, we can use the same script to visualize the results. \
In addition to saving correlations between parcels and segmentation signals, the script `feature_parcel_correlation/Feature_Parcel_Correlations.rnw` can also plot these correlations on individual brain slices on the knitr pdf output at `feature_parcel_correlation/Feature_Parcel_Correlations.pdf`
To visualize distributions of correlations, we have different types of plots at: `voxelwiseAnalyses/feature_parcel_correlation/plot_correlation_distributions.ipynb`. (e.g. within a network across parcels, across networks, etc.) \
To compare different preprocessing pipelines' timeseries correlation with segmentation signals, `voxelwiseAnalyses/parcel_timeseries/compare_preprocessing_pipelines.ipynb` plots the diagonal plots of correlations with pixel change mean to contrast two different preprocessing pipelines.

### Brain regions tracking behavioral event boundaries
#### Methods
We treat event boundaries identified by each participant in their session 2 as if they are event boundaries that they experience while they were in the fMRI scanner. \
We then run a Finite Impulse Response (FIR) model on the voxel BOLD timeseries or each subject to identify brain regions that track event boundaries, using AFNI. \
##### Prepare input to AFNI
###### Prepare regressors, masking list, and blur/scale/lpi-orient data
To prepare input to AFNI to run FIR, we need to prepare 6 motion regressors, a list of TRs that should be masked because they have high framewise displacement (FD), and voxel BOLD timeseries that are blurred, scaled, and lpi-oriented from fmriprep data. \
To create input to AFNI, run 
``` /bin/bash voxelwiseAnalyses/finite_impulse_response/StroopCW_PreGLM_2023.03.17 - Copy.sh
```
###### Prepare event files
To prepare input to AFNI to run FIR, we need events (regressors of interest). Event boundary has two grains, fine and coarse, and we are interested in both fine boundaries and coarse boundaries. \
Events file were created by running `voxelwiseAnalyses/finite_impulse_response/afni_events_from_segmentation.ipynb`. Output is saved in `voxelwiseAnalyses/finite_impulse_response/EVTs/` \

For runs that should be excluded from GLMs or do not have boundary data from participants, they receive an "*" in the event files. This approach is consistent with the strategy to preprocess all subjects/sessions, and filter out people in real analysis \

##### Run GLMs with AFNI
The template is copied from `/data/nil-bluearc/ccp-hcp/StroopCW/CODE/GLMcode/GLMs_vol.R` to `voxelwiseAnalyses/finite_impulse_response/GLMs_vol.R` \
Results are saved at `voxelwiseAnalyses/finite_impulse_response/AFNI_ANALYSIS/sub-02/RESULTS/` \
###### Design Matrices
For each "event" (a fine boundary or a coarse boundary), we are interested in 10 seconds before the boundary and 10 seconds after the boundary. Thus, we used TENT(-10, 10, 11): 11 knots, 2s interval, from -10s to 10s of the "event" \
We run GLMs for each voxel with three design matrices. \
A design matrix with only fine event boundaries. This analysis identifies voxels responsive to fine event boundaries, by looking at coefficients of 11 knots. \
A design matrix with only coarse event boundaries. This analysis identifies voxels responsive to coarse event boundaries, by looking at coefficients of 11 knots. \
A design matrix with both coarse and fine event boundaries. The above analyses might be confounded. The idea is that, conceptually coarse event segmentation (e.g. making coffee -> preparing a bagel) usually encloses or coincides with fine segmentation (e.g. pouring coffee to the cup -> fetching a bagel from a drawer). Suppose there's a brain region that is "sensitive only to fine event boundaries," when we run GLMs separately (with the two analyses above), we'll likely see this brain region responding to both fine event boundaries and coarse event boundaries (high coefficients). When we include both fine boundaries and coarse boundaries as independent variables in GLMs, coefficients of coarse boundaries for that brain region will likely be around 0s. On the other hand, a brain region that is sensitive to coarse event boundaries, above and beyond fine event boundaries will likely have high coefficients for coarse event boundaries. Conversely, a brain region that is only responsive to coarse boundaries can also have high coefficients in the fine event boundary analysis. This analysis tries to parcel out the correlation between fine event boundaries and coarse event boundaries. A drawback is that a high correlation between fine event boundaries and coarse event boundaries can reduce statistical power a lot. \
#### Visualize Results
AFNI output a lot of statistics, we are interested in coefficients of regressors of interest (knots). We use `voxelwiseAnalyses/finite_impulse_response/knitr/sub01_brains/sub01_GLMs_brains.rnw` to visualize the results. \