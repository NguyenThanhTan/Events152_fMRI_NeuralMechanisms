# Prepare input to AFNI
## Prepare regressors, masking list, and blur/scale/lpi-orient data
/data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/voxelwiseAnalyses/finite_impulse_response/StroopCW_PreGLM_2023.03.17.sh was copied from /data/nil-bluearc/ccp-hcp/StroopCW/CODE/StroopCW_PreGLM_2023.03.17.sh
Then, a copy was made and adapted to work with movie-watching fmriprep data. /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/voxelwiseAnalyses/finite_impulse_response/StroopCW_PreGLM_2023.03.17 - Copy.sh
## Prepare event files
Event boundary has two grain, fine and coarse. Segmentation data (/data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/voxelwiseAnalyses/finite_impulse_response/segmentation.csv) was copied from Box\DCL_ARCHIVE\Documents\Events\exp152_fMRIneuralmechanisms\Analysis\segmentation.csv, it was created by running Box\DCL_ARCHIVE\Documents\Events\exp152_fMRIneuralmechanisms\Analysis\analyze_session_segmentation_only.py on 07/11/2022 (the last participant was in 05/28/2022, so this should have segmentation data for all subjects)

Events file were created by running /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/voxelwiseAnalyses/finite_impulse_response/afni_events_from_segmentation.ipynb

For runs that should be excluded from GLMs or do not have boundary data from participants, they receive an "*" in the event files. This approach is consistent with the strategy to preprocess all subjects/sessions, and filter out people in real analysis

## Run GLMs
The template is copied from /data/nil-bluearc/ccp-hcp/StroopCW/CODE/GLMcode/GLMs_vol.R to /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/voxelwiseAnalyses/finite_impulse_response/GLMs_vol.R
Jo made some comments and changes, saved at /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/voxelwiseAnalyses/finite_impulse_response/GLMs_vol_Jo.R