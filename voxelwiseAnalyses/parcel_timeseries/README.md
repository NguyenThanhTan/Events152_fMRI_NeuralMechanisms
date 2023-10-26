`xcp_*/` and `np2/` folders contain preprocessed BOLD data. 

XCPparam directory contains design files for XCPengine. Two bash scripts are provided to run XCPengine on Penfield (with installed singularity and xcpengine images).

XCPengine outputs are stored in `xcp_*/` folders.

```1d_bold_to_csvs.ipynb``` converts XCPengine outputs to csv files and add timing difference between TR onset and movie onset information, saved csv files in `/data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/voxelwiseAnalyses/parcel_timeseries/xcp_24p_gsr_csv/`. easy to share with others. In csv files, 0 in the column `time_second` correspond with the onset of the movie.

Difference between TR onset and movie onset information is stored in  `/data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/voxelwiseAnalyses/subject_movie_onset/e152onsets.txt`