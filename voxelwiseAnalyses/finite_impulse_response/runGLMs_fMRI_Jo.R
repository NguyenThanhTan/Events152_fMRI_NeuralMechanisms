#########################################################################################################################################
# fMRI 152 movie watching GLM-running code

# need to omit sub-10, 11 entirely for movement;  sub25 run1 & sub42 run2.

# sub-38 missing coarse EVT!? ... yes, they're missing coarse & fine; no EVTs directory.

#########################################################################################################################################
#########################################################################################################################################
# This script calls other R scripts to run the GLMs for a single person. 
# Before running this script the EVTs must be made, fmriprep run, and the preGLM script finished. 

rm(list=ls());    # clear R's memory
options(warnPartialMatchDollar=TRUE);  

#source("/data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/voxelwiseAnalyses/finite_impulse_response/GLMs_vol_Jo.R");
source("/data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/voxelwiseAnalyses/finite_impulse_response/GLMs_vol_TENT20_Jo.R");

for (sub.id in paste0("sub-", 21:47)) {   # sub.id <- "sub-42";     
  print(paste("starting", sub.id));
  
  # Note: there are multiple GLMs. These functions will run all of them.
  in.path <- "/data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/voxelwiseAnalyses/finite_impulse_response/";
  #out.path <- paste0(in.path, "AFNI_ANALYSIS/", sub.id, "/RESULTS/");
  out.path <- paste0(in.path, "AFNI_ANALYSIS/", sub.id, "/RESULTS_TENT20/");
  if (!dir.exists(out.path)) { dir.create(out.path); }
  
  # # pipe output of the do.GLMs.vol function into a log file
  # log_file <- paste0(out.path, sub.id, "_log.txt")
  # # this only capture R's output, not from system commands (afni).
  # # thus, inside do.GLMs.vol, if there are system commands, should be converted to R print/cat
  # sink(log_file)
  # do.GLMs.vol(sub.id);
  # sink()
  
  do.parcelavg.vol(sub.id); 
}
