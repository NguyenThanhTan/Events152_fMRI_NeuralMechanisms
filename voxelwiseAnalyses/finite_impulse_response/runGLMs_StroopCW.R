#########################################################################################################################################
# StroopCW GLM-running code
#########################################################################################################################################
#########################################################################################################################################
# This script calls other R scripts to run the GLMs for a single person. 
# Before running this script the EVTs must be made, fmriprep run, and the preGLM script finished. 
# This code should be run on ccplinux1, and may take a few hours. AFNI will print many messages to the console as these functions run.
# If all goes well, the final thing printed by each function will be a success message.
# If you want to use RStudio while these functions are running, start an R console window (Applications -> Graphics -> R) and 
# copy-paste (or source) the commands from this file into it.

# You should only need to change the sub.id in this file. 
# For each, run the volume functions first, and then the surface (not just volume).
# If error messages are printed and you're not sure why, contact Jo.

rm(list=ls());    # clear R's memory
options(warnPartialMatchDollar=TRUE);  

source("/data/nil-bluearc/ccp-hcp/StroopCW/CODE/GLMcode/GLMs_vol.R");
source("/data/nil-bluearc/ccp-hcp/StroopCW/CODE/GLMcode/GLMs_surf.R");



#**** change the line of code below here to match the subject id ****#

sub.id <- "SCW994";     

#**** should usually not need to change the lines of code below here ****#

# Note: there are multiple GLMs. By default these functions will run all of them.
# If output for one GLM already exists, or you otherwise want to skip one, add do.ONs=FALSE, do.CueType=FALSE, do.Valence=FALSE
# as parameters after the sub.id. e.g., do.GLMs.vol(sub.id, do.ONs=FALSE); will have it run CueType and Valence only, skipping ONs.

# volume
do.GLMs.vol(sub.id, "Bas"); do.GLMs.vol(sub.id, "Pro"); do.GLMs.vol(sub.id, "Rea");


#do.GLMs.vol(sub.id, "Rea", do.ON_TRIALS=FALSE, do.ON_BLOCKS=FALSE, do.ON_MIXED=FALSE, do.ON_MIXED_CUE=FALSE); 
# do.parcelavg.vol(sub.id, "Rea", do.ON_TRIALS=FALSE, do.ON_BLOCKS=FALSE, do.ON_MIXED=FALSE, do.ON_MIXED_CUE=FALSE); 


# if do.GLMs.vol(sub.id) did not make an error
do.parcelavg.vol(sub.id, "Bas"); do.parcelavg.vol(sub.id, "Pro"); do.parcelavg.vol(sub.id, "Rea");    


# surface:  (do volume first)
do.GLMs.surf(sub.id, "Bas"); do.GLMs.surf(sub.id, "Pro"); do.GLMs.surf(sub.id, "Rea");
# only run if do.GLMs.surf(sub.id) did not make an error
do.parcelavg.surf(sub.id, "Bas"); do.parcelavg.surf(sub.id, "Pro"); do.parcelavg.surf(sub.id, "Rea");   


#########################################################################################################################################
#########################################################################################################################################

