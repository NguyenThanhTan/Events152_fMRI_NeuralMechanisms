#########################################################################################################################################
# fMRI 152 movie watchting GLM-running code
#########################################################################################################################################
#########################################################################################################################################
# This script calls other R scripts to run the GLMs for a single person. 
# Before running this script the EVTs must be made, fmriprep run, and the preGLM script finished. 

rm(list=ls());    # clear R's memory
options(warnPartialMatchDollar=TRUE);  

source("/data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/voxelwiseAnalyses/finite_impulse_response/GLMs_vol.R");
# source("/data/nil-bluearc/ccp-hcp/StroopCW/CODE/GLMcode/GLMs_surf.R");

sub.id <- "sub-15";     

# Note: there are multiple GLMs. By default these functions will run all of them.
# If output for one GLM already exists, or you otherwise want to skip one, add do.ON_FINE=FALSE, 

in.path <- "/data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/voxelwiseAnalyses/finite_impulse_response/";
out.path <- paste0(in.path, "AFNI_ANALYSIS/", sub.id, "/RESULTS/");
if (!dir.exists(out.path)) { dir.create(out.path); }

# pipe output of the do.GLMs.vol function into a log file
log_file <- paste0(out.path, sub.id, "_log.txt")
# this only capture R's output, not from system commands (afni).
# thus, inside do.GLMs.vol, if there are system commands, should be converted to R print/cat
sink(log_file)
do.GLMs.vol(sub.id, do.ON_FINE=TRUE, do.ON_BOTH=TRUE, do.ON_COARSE=TRUE)
sink()

# log_file <- paste0(out.path, sub.id, "_log_parcel_avg.txt")
# sink(log_file)
do.parcelavg.vol(sub.id, do.ON_FINE=FALSE, do.ON_BOTH=TRUE, do.ON_COARSE=FALSE); 
# sink()

#do.GLMs.vol(sub.id, "Rea", do.ON_TRIALS=FALSE, do.ON_BLOCKS=FALSE, do.ON_MIXED=FALSE, do.ON_MIXED_CUE=FALSE); 
# do.parcelavg.vol(sub.id, "Rea", do.ON_TRIALS=FALSE, do.ON_BLOCKS=FALSE, do.ON_MIXED=FALSE, do.ON_MIXED_CUE=FALSE); 


# if do.GLMs.vol(sub.id) did not make an error
# do.parcelavg.vol(sub.id, "Bas"); do.parcelavg.vol(sub.id, "Pro"); do.parcelavg.vol(sub.id, "Rea");    
