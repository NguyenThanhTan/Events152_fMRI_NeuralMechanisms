# Data
## Data Collection

The were two-sessions for each participant. In session 1, participants watched 4 activities while being in the scanner. In session 2, participants are asked to free-recall, then perform Yes/No recognition task. Then, participants watched activities again twice and were asked to segment these activities into meaninggul events (one at fine-grain and one at coarse-grain level). 

## fMRI data
### fMRIprep Voxel BOLD Timeseries
fMRIprep voxel BOLD timeseries are saved at: `fmriprep/fmriprep/` 
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
The script to correlate BOLD timeseries with visual features is at: `voxelwiseAnalyses/feature_parcel_correlation/Feature_Parcel_Correlations.rnw`. The correlation results are saved at: `/voxelwiseAnalyses/feature_parcel_correlation/pcm_xcp_24p_gsr_corrs_1_550` or `voxelwiseAnalyses/feature_parcel_correlation/pcm_np2_corrs_1_550` depending on which preprocessing output you decide to correlate with visual features (pcm = pixel change mean in this case).

#### Visualize Results
In addition to saving correlations between parcels and visual features, the script `feature_parcel_correlation/Feature_Parcel_Correlations.rnw` can also plot these correlations on individual brain slices on the knitr pdf output at `feature_parcel_correlation/Feature_Parcel_Correlations.pdf`
To visualize distributions of correlations, we have different types of plots at: `voxelwiseAnalyses/feature_parcel_correlation/plot_correlation_distributions.ipynb`. (e.g. within a network across parcels, across networks, etc.)\
To compare different preprocessing pipelines' timeseries correlation with pixel change mean, `voxelwiseAnalyses/parcel_timeseries/compare_preprocessing_pipelines.ipynb` plots the diagonal plots of correlations with pixel change mean to contrast two different preprocessing pipelines.


## Behavioral data
Participants came back for a second session, where they were asked to free-recall, then perform Yes/No recognition task. Then, participants watched activities again twice and were asked to segment these activities into meaninggul events (one at fine-grain and one at coarse-grain level; counter-balance). \
Raw data (from Psychopy) is at `data/`. \
Script to process raw data into free-recall and recognition and segmentation is at: `Analysis/analyze_session_two.ipynb`. The result is saved at: `Analysis/memory_df.csv` and  `Analysis/segmentation_df_08_15_2023.csv`



## Hypothesis testing
### Brain regions tracking continuous segmentation signals
#### Methods
We treat the computational model (SEM) as an instrument, measuring prediction error and uncertainty that people experience in the 4 activities. We correlate SEM's prediction error and uncertainty with neural activity in different parcels to determine brain parcels tracking these signals. \
For this exploratory analysis, we need to correct for multiple comparisons. We use FDR to correct for multiple comparisons. \

Details on how to run this analysis are in `voxelwiseAnalyses/feature_parcel_correlation/README.md`



### Brain regions tracking behavioral event boundaries
#### Methods
We treat event boundaries identified by each participant in their session 2 as if they are event boundaries that they experience while they were in the fMRI scanner. \
We then run a Finite Impulse Response (FIR) model on the voxel BOLD timeseries or each subject to identify brain regions that track event boundaries, using AFNI. \
Technical details on how to run this analysis is described at `voxelwiseAnalyses/finite_impulse_response/README.md`
