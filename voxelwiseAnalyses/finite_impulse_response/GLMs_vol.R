# StroopCW GLMs: volumes
# started 17 March 2023 by Jo. See the StroopCW Task Design boxnote, https://wustl.app.box.com/notes/1086025740387
# EVTs made with makeEVTs_StroopCW.R

# need at least half the fMRI data; each mode (bas, pro, rea) should have two runs
# a bit trickier since blocks not evenly distributed; need more like half of the second run to have more
# than half the data of both Color and Word


# TENTzero(0,16.8,15) same as DMCC Stroop https://wustl.app.box.com/notes/302343634990

###############################################################################################################################################################
###############################################################################################################################################################

in.path <- "/data/nil-bluearc/ccp-hcp/StroopCW/";  
afni.path <- "/usr/local/pkg/afni_22/";   # path to the afni function executables
p.path <- "/data/nil-bluearc/ccp-hcp/StroopCW/ATLASES/";   # parcellations

# the do. parameters control if running the corresponding GLM is attempted; e.g., to skip do.ON_BLOCKS, set do.ON_BLOCKS=FALSE.
do.GLMs.vol <- function(sub.id, sess.id, do.ON_BLOCKS=TRUE, do.ON_MIXED=TRUE, do.ON_MIXED_CUE=TRUE,
                        do.ON_TRIALS=TRUE, do.CongruencyCW=TRUE) {     
  # sub.id <- "SCW994"; sess.id <- "Bas"; do.ON_MIXED <- TRUE; do.ON_MIXED_CUE <- TRUE;
  was.success <- TRUE;   # initialize return value 
  
  # use full name in output directories, for consistency with DMCC
  if (sess.id == "Bas") { session.id <- "baseline"; }
  if (sess.id == "Pro") { session.id <- "proactive"; }
  if (sess.id == "Rea") { session.id <- "reactive"; }
  
  evt.path <- paste0(in.path, "EVTs/", sub.id, "/"); # to shorten paths later
  
  
  # check for input files needed for all the GLMs
  c.fname <- paste0(in.path, "DATA/AFNI_ANALYSIS/", sub.id, "/INPUT_DATA/", sub.id, "_Stroop", sess.id, "_FD_mask.txt");     # 0 1 $censor_file
  if (!file.exists(c.fname)) { print(paste("ERROR: didn't find censor file", c.fname)); was.success <- FALSE; }
  
  ort.fname <- paste0(in.path, "DATA/AFNI_ANALYSIS/", sub.id, "/INPUT_DATA/", sub.id, "_Stroop", sess.id, "_6regressors.txt");
  if (!file.exists(ort.fname)) { print(paste("ERROR: didn't find ort file", ort.fname)); was.success <- FALSE; }
  
  mot.fname <- paste0(in.path, "DATA/AFNI_ANALYSIS/", sub.id, "/INPUT_DATA/", sub.id, "_Stroop", sess.id, "_6regressors_demean.txt");  # ${motion_file}
  if (!file.exists(mot.fname)) { print(paste("ERROR: didn't find mot file", mot.fname)); was.success <- FALSE; }
  
  # and the bold runs; need both of each run (though not checking for duration yet)
  bold1.fname <- paste0(in.path, "DATA/AFNI_ANALYSIS/", sub.id, "/INPUT_DATA/lpi_scale_blur6_sub-", 
                        sub.id, "_ses-1_task-Stroop", sess.id, "_run-1_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz");
  bold2.fname <- paste0(in.path, "DATA/AFNI_ANALYSIS/", sub.id, "/INPUT_DATA/lpi_scale_blur6_sub-",
                        sub.id, "_ses-1_task-Stroop", sess.id, "_run-2_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz");
  
  # strings to hold the bold filenames; slightly different syntax for the two afni commands
  if (file.exists(bold1.fname) & file.exists(bold2.fname)) { 
    input.str.decon <- paste0("-input '", bold1.fname, "' '", bold2.fname, "'");
    input.str.reml  <- paste0('-input "', bold1.fname, " ", bold2.fname, '"');
  } else {
    input.str.decon <- "";
    input.str.reml <- "";
    print("didn't find one or both bold.nii.gz"); 
    was.success <- FALSE;
  }
  rm(bold1.fname, bold2.fname);  # cleanup
  
  # and check for previous output - afni won't overwrite, so stop if find files
  fname1 <- paste0(in.path, "DATA/AFNI_ANALYSIS/", sub.id, "/RESULTS/", session.id, "_ON_TRIALS/STATS_", sub.id, "_REML.nii.gz");  
  if (do.ON_TRIALS == TRUE & file.exists(fname1)) { 
    print(paste0("ERROR: /RESULTS/", session.id, "_ON_TRIALS/STATS_", sub.id, "_REML.nii.gz already exists but do.ON_TRIALS=TRUE.")); 
    was.success <- FALSE; 
  }
  
  fname2 <- paste0(in.path, "DATA/AFNI_ANALYSIS/", sub.id, "/RESULTS/", session.id, "_ON_BLOCKS/STATS_", sub.id, "_REML.nii.gz");  
  if (do.ON_BLOCKS == TRUE & file.exists(fname2)) { 
    print(paste0("ERROR: /RESULTS/", session.id, "_ON_BLOCKS/STATS_", sub.id, "_REML.nii.gz already exists but do.ON_BLOCKS=TRUE.")); 
    was.success <- FALSE; 
  }
  
  fname3 <- paste0(in.path, "DATA/AFNI_ANALYSIS/", sub.id, "/RESULTS/", session.id, "_ON_MIXED/STATS_", sub.id, "_REML.nii.gz");  
  if (do.ON_MIXED == TRUE & file.exists(fname3)) { 
    print(paste0("ERROR: /RESULTS/", session.id, "_ON_MIXED/STATS_", sub.id, "_REML.nii.gz already exists but do.ON_MIXED=TRUE.")); 
    was.success <- FALSE; 
  }
  
  fname4 <- paste0(in.path, "DATA/AFNI_ANALYSIS/", sub.id, "/RESULTS/", session.id, "_ON_MIXED_CUE/STATS_", sub.id, "_REML.nii.gz");  
  if (do.ON_MIXED_CUE == TRUE & file.exists(fname4)) { 
    print(paste0("ERROR: /RESULTS/", session.id, "_ON_MIXED_CUE/STATS_", sub.id, "_REML.nii.gz already exists but do.ON_MIXED_CUE=TRUE.")); 
    was.success <- FALSE; 
  }
  
  fname5 <- paste0(in.path, "DATA/AFNI_ANALYSIS/", sub.id, "/RESULTS/", session.id, "_CongruencyCW/STATS_", sub.id, "_REML.nii.gz");  
  if (do.CongruencyCW == TRUE & file.exists(fname5)) { 
    print(paste0("ERROR: /RESULTS/", session.id, "_CongruencyCW/STATS_", sub.id, "_REML.nii.gz already exists but do.CongruencyCW=TRUE.")); 
    was.success <- FALSE; 
  }
  
  
  if (was.success == TRUE) {    # so far, so good, so keep going
    out.path <- paste0(in.path, "DATA/AFNI_ANALYSIS/", sub.id, "/RESULTS/");
    if (!dir.exists(out.path)) { dir.create(out.path); }   # make the top-level output directory if needed
    
    # # # # # # ON_BLOCKS GLM: volume # # # # # # 
    if (do.ON_BLOCKS == TRUE) {
      # make the output directories
      out.path <- paste0(in.path, "DATA/AFNI_ANALYSIS/", sub.id, "/RESULTS/", session.id, "_ON_BLOCKS/");  # actual output directory
      if (!dir.exists(out.path)) { dir.create(out.path); }
      setwd(out.path);  # needed for afni to write files in proper directory
      
      # call AFNI to do the GLM
      system2(paste0(afni.path, "3dDeconvolve"),
              args=paste0("-local_times -x1D_stop -GOFORIT 5 ", input.str.decon, " -polort A -float ",
                          "-censor ", c.fname, " -num_stimts 1 ",
                          "-stim_times_AM1 1 ", evt.path, sub.id, "_StroopCW_", session.id, "_block.txt 'dmBLOCK(1)' -stim_label 1 ON_BLOCKS ",
                          "-ortvec ", mot.fname, " motion -x1D X.xmat.1D -xjpeg X.jpg -nobucket"), stdout=TRUE);
      
      system2(paste0(afni.path, "3dREMLfit"), args=paste0("-matrix X.xmat.1D -GOFORIT 5 ", input.str.reml, " ",
                                                          "-Rvar stats_var_", sub.id, "_REML.nii.gz ",
                                                          "-Rbuck STATS_", sub.id, "_REML.nii.gz ",
                                                          "-fout -tout -nobout -verb"), stdout=TRUE);
    }
    
    
    # # # # # # ON_MIXED GLM: volume # # # # # # 
    if (do.ON_MIXED == TRUE) {
      # make the output directories
      out.path <- paste0(in.path, "DATA/AFNI_ANALYSIS/", sub.id, "/RESULTS/", session.id, "_ON_MIXED/");  # actual output directory
      if (!dir.exists(out.path)) { dir.create(out.path); }
      setwd(out.path);  # needed for afni to write files in proper directory
      
      # call AFNI to do the GLM
      system2(paste0(afni.path, "3dDeconvolve"),
              args=paste0("-local_times -x1D_stop -GOFORIT 5 ", input.str.decon, " -polort A -float ",
                          "-censor ", c.fname, " -num_stimts 3 ",
                          "-stim_times_AM1 1 ", evt.path, sub.id, "_StroopCW_", session.id, "_block.txt 'dmBLOCK(1)' -stim_label 1 ON_BLOCKS ",
                          "-stim_times 2 ", evt.path, sub.id, "_StroopCW_", session.id, "_blockCUEandOFF.txt 'TENTzero(0,16.8,15)' -stim_label 2 ON_blockCUEandOFF ",
                          "-stim_times 3 ", evt.path, sub.id, "_StroopCW_", session.id, "_allTrials.txt 'TENTzero(0,16.8,15)' -stim_label 3 ON_TRIALS ",
                          "-ortvec ", mot.fname, " motion -x1D X.xmat.1D -xjpeg X.jpg -nobucket"), stdout=TRUE);
      
      system2(paste0(afni.path, "3dREMLfit"), args=paste0("-matrix X.xmat.1D -GOFORIT 5 ", input.str.reml, " ",
                                                          "-Rvar stats_var_", sub.id, "_REML.nii.gz ",
                                                          "-Rbuck STATS_", sub.id, "_REML.nii.gz ",
                                                          "-fout -tout -nobout -verb"), stdout=TRUE);
    }
    
    
    
    # # # # # # ON_MIXED_CUE GLM: volume # # # # # # 
    # BLOCK(3,1) for cue since cue is shown for 3 seconds.
    if (do.ON_MIXED_CUE == TRUE) {
      # make the output directories
      out.path <- paste0(in.path, "DATA/AFNI_ANALYSIS/", sub.id, "/RESULTS/", session.id, "_ON_MIXED_CUE/");  # actual output directory
      if (!dir.exists(out.path)) { dir.create(out.path); }
      setwd(out.path);  # needed for afni to write files in proper directory
      
      # call AFNI to do the GLM
      system2(paste0(afni.path, "3dDeconvolve"),
              args=paste0("-local_times -x1D_stop -GOFORIT 5 ", input.str.decon, " -polort A -float ",
                          "-censor ", c.fname, " -num_stimts 3 ",
                          "-stim_times_AM1 1 ", evt.path, sub.id, "_StroopCW_", session.id, "_block.txt 'dmBLOCK(1)' -stim_label 1 ON_BLOCKS ",
                          "-stim_times 2 ", evt.path, sub.id, "_StroopCW_", session.id, "_cue.txt 'BLOCK(3,1)' -stim_label 2 cue ",
                          "-stim_times 3 ", evt.path, sub.id, "_StroopCW_", session.id, "_allTrials.txt 'TENTzero(0,16.8,15)' -stim_label 3 ON_TRIALS ",
                          "-ortvec ", mot.fname, " motion -x1D X.xmat.1D -xjpeg X.jpg -nobucket"), stdout=TRUE);
      
      system2(paste0(afni.path, "3dREMLfit"), args=paste0("-matrix X.xmat.1D -GOFORIT 5 ", input.str.reml, " ",
                                                          "-Rvar stats_var_", sub.id, "_REML.nii.gz ",
                                                          "-Rbuck STATS_", sub.id, "_REML.nii.gz ",
                                                          "-fout -tout -nobout -verb"), stdout=TRUE);
    }
    
    
    # # # # # # ON_TRIALS GLM: volume # # # # # # 
    if (do.ON_TRIALS == TRUE) {
      # make the output directories
      out.path <- paste0(in.path, "DATA/AFNI_ANALYSIS/", sub.id, "/RESULTS/", session.id, "_ON_TRIALS/");  # actual output directory
      if (!dir.exists(out.path)) { dir.create(out.path); }
      setwd(out.path);  # needed for afni to write files in proper directory
      
      # call AFNI to do the GLM
      system2(paste0(afni.path, "3dDeconvolve"),
              args=paste0("-local_times -x1D_stop -GOFORIT 5 ", input.str.decon, " -polort A -float ",
                          "-censor ", c.fname, " -num_stimts 1 ",
                          "-stim_times 1 ", evt.path, sub.id, "_StroopCW_", session.id, "_allTrials.txt 'TENTzero(0,16.8,15)' -stim_label 1 ON_TRIALS ",
                          "-ortvec ", mot.fname, " motion -x1D X.xmat.1D -xjpeg X.jpg -nobucket"), stdout=TRUE);
      
      system2(paste0(afni.path, "3dREMLfit"), args=paste0("-matrix X.xmat.1D -GOFORIT 5 ", input.str.reml, " ",
                                                          "-Rvar stats_var_", sub.id, "_REML.nii.gz ",
                                                          "-Rbuck STATS_", sub.id, "_REML.nii.gz ",
                                                          "-fout -tout -nobout -verb"), stdout=TRUE);
    }
    
    
    # # # # # # CongruencyCW GLM: volume # # # # # # 
    if (do.CongruencyCW == TRUE) {
      # make the output directories
      out.path <- paste0(in.path, "DATA/AFNI_ANALYSIS/", sub.id, "/RESULTS/", session.id, "_CongruencyCW/");  # actual output directory
      if (!dir.exists(out.path)) { dir.create(out.path); }
      setwd(out.path);  # needed for afni to write files in proper directory
      
      # call AFNI to do the GLM
      if (session.id == "reactive") {    # buffConC and buffConW are *only* in the reactive GLM.
        system2(paste0(afni.path, "3dDeconvolve"),
                args=paste0("-local_times -x1D_stop -GOFORIT 5 ", input.str.decon, " -polort A -float ",
                            "-censor ", c.fname, " -num_stimts 13 ",
                            "-stim_times_AM1 1 ", evt.path, sub.id, "_StroopCW_", session.id, "_blockC.txt 'dmBLOCK(1)' -stim_label 1 blockC ",
                            "-stim_times_AM1 2 ", evt.path, sub.id, "_StroopCW_", session.id, "_blockW.txt 'dmBLOCK(1)' -stim_label 2 blockW ",
                            "-stim_times 3 ",  evt.path, sub.id, "_StroopCW_", session.id, "_blockCUEandOFF.txt 'TENTzero(0,16.8,15)' -stim_label 3 blockCUEandOFF ",
                            "-stim_times 4 ",  evt.path, sub.id, "_StroopCW_", session.id, "_PC50ConC.txt 'TENTzero(0,16.8,15)' -stim_label 4 PC50ConC ",
                            "-stim_times 5 ",  evt.path, sub.id, "_StroopCW_", session.id, "_PC50ConW.txt 'TENTzero(0,16.8,15)' -stim_label 5 PC50ConW ",
                            "-stim_times 6 ",  evt.path, sub.id, "_StroopCW_", session.id, "_PC50InConC.txt 'TENTzero(0,16.8,15)' -stim_label 6 PC50InConC ",
                            "-stim_times 7 ",  evt.path, sub.id, "_StroopCW_", session.id, "_PC50InConW.txt 'TENTzero(0,16.8,15)' -stim_label 7 PC50InConW ",
                            "-stim_times 8 ",  evt.path, sub.id, "_StroopCW_", session.id, "_biasConC.txt 'TENTzero(0,16.8,15)' -stim_label 8 biasConC ",
                            "-stim_times 9 ",  evt.path, sub.id, "_StroopCW_", session.id, "_biasConW.txt 'TENTzero(0,16.8,15)' -stim_label 9 biasConW ",
                            "-stim_times 10 ", evt.path, sub.id, "_StroopCW_", session.id, "_biasInConC.txt 'TENTzero(0,16.8,15)' -stim_label 10 biasInConC ",
                            "-stim_times 11 ", evt.path, sub.id, "_StroopCW_", session.id, "_biasInConW.txt 'TENTzero(0,16.8,15)' -stim_label 11 biasInConW ",
                            "-stim_times 12 ", evt.path, sub.id, "_StroopCW_", session.id, "_buffConC.txt 'TENTzero(0,16.8,15)' -stim_label 12 buffConC ",
                            "-stim_times 13 ", evt.path, sub.id, "_StroopCW_", session.id, "_buffConW.txt 'TENTzero(0,16.8,15)' -stim_label 13 buffConW ",
                            "-ortvec ", mot.fname, " motion -x1D X.xmat.1D -xjpeg X.jpg -nobucket"), stdout=TRUE);
      } else {
        system2(paste0(afni.path, "3dDeconvolve"),
                args=paste0("-local_times -x1D_stop -GOFORIT 5 ", input.str.decon, " -polort A -float ",
                            "-censor ", c.fname, " -num_stimts 11 ",
                            "-stim_times_AM1 1 ", evt.path, sub.id, "_StroopCW_", session.id, "_blockC.txt 'dmBLOCK(1)' -stim_label 1 blockC ",
                            "-stim_times_AM1 2 ", evt.path, sub.id, "_StroopCW_", session.id, "_blockW.txt 'dmBLOCK(1)' -stim_label 2 blockW ",
                            "-stim_times 3 ",  evt.path, sub.id, "_StroopCW_", session.id, "_blockCUEandOFF.txt 'TENTzero(0,16.8,15)' -stim_label 3 blockCUEandOFF ",
                            "-stim_times 4 ",  evt.path, sub.id, "_StroopCW_", session.id, "_PC50ConC.txt 'TENTzero(0,16.8,15)' -stim_label 4 PC50ConC ",
                            "-stim_times 5 ",  evt.path, sub.id, "_StroopCW_", session.id, "_PC50ConW.txt 'TENTzero(0,16.8,15)' -stim_label 5 PC50ConW ",
                            "-stim_times 6 ",  evt.path, sub.id, "_StroopCW_", session.id, "_PC50InConC.txt 'TENTzero(0,16.8,15)' -stim_label 6 PC50InConC ",
                            "-stim_times 7 ",  evt.path, sub.id, "_StroopCW_", session.id, "_PC50InConW.txt 'TENTzero(0,16.8,15)' -stim_label 7 PC50InConW ",
                            "-stim_times 8 ",  evt.path, sub.id, "_StroopCW_", session.id, "_biasConC.txt 'TENTzero(0,16.8,15)' -stim_label 8 biasConC ",
                            "-stim_times 9 ",  evt.path, sub.id, "_StroopCW_", session.id, "_biasConW.txt 'TENTzero(0,16.8,15)' -stim_label 9 biasConW ",
                            "-stim_times 10 ", evt.path, sub.id, "_StroopCW_", session.id, "_biasInConC.txt 'TENTzero(0,16.8,15)' -stim_label 10 biasInConC ",
                            "-stim_times 11 ", evt.path, sub.id, "_StroopCW_", session.id, "_biasInConW.txt 'TENTzero(0,16.8,15)' -stim_label 11 biasInConW ",
                            "-ortvec ", mot.fname, " motion -x1D X.xmat.1D -xjpeg X.jpg -nobucket"), stdout=TRUE);
      }
      
      # same for all sessions; buffConC and buffConW are not used in any contrasts.
      system2(paste0(afni.path, "3dREMLfit"), 
              args=paste0("-matrix X.xmat.1D -GOFORIT 5 ", input.str.reml, " ",
                          "-gltsym 'SYM: +biasInConC[[0..12]] -biasConC[[0..12]]' InCon_Con_biasC ",
                          "-gltsym 'SYM: +biasInConW[[0..12]] -biasConW[[0..12]]' InCon_Con_biasW ",
                          "-gltsym 'SYM: +PC50InConC[[0..12]] -PC50ConC[[0..12]]' InCon_Con_PC50C ",
                          "-gltsym 'SYM: +PC50InConW[[0..12]] -PC50ConW[[0..12]]' InCon_Con_PC50W ",
                          "-gltsym 'SYM: +0.5*biasInConC[[0..12]] +0.5*PC50InConC[[0..12]] -0.5*biasConC[[0..12]] -0.5*PC50ConC[[0..12]]' InCon_Con_PC50biasC ",
                          "-gltsym 'SYM: +0.5*biasInConW[[0..12]] +0.5*PC50InConW[[0..12]] -0.5*biasConW[[0..12]] -0.5*PC50ConW[[0..12]]' InCon_Con_PC50biasW ",
                          "-gltsym 'SYM: +blockC -blockW' C_W_block ",   # not TENTS
                          "-gltsym 'SYM: +0.5*biasInConC[[0..12]] +0.5*PC50InConC[[0..12]] -0.5*biasInConW[[0..12]] -0.5*PC50InConW[[0..12]]' C_W_InCon ",
                          "-gltsym 'SYM: +biasInConC[[0..12]] -biasInConW[[0..12]]' C_W_biasInCon ",
                          "-gltsym 'SYM: +PC50InConC[[0..12]] -PC50InConW[[0..12]]' C_W_PC50InCon ",
                          "-Rvar stats_var_", sub.id, "_REML.nii.gz ",
                          "-Rbuck STATS_", sub.id, "_REML.nii.gz ",
                          "-fout -tout -nobout -verb"), stdout=TRUE);
    }
    
    
    
    # STATS didn't all exist before, so check if expected ones are present now
    if (do.ON_TRIALS & !file.exists(fname1)) { was.success <- FALSE; }
    if (do.ON_BLOCKS & !file.exists(fname2)) { was.success <- FALSE; }
    if (do.ON_MIXED & !file.exists(fname3)) { was.success <- FALSE; }
    if (do.ON_MIXED_CUE & !file.exists(fname4)) { was.success <- FALSE; }
    if (do.CongruencyCW & !file.exists(fname5)) { was.success <- FALSE; }
  }
  
  if (was.success) { print(paste("do.GLMs.vol", sess.id, "finished successfully!")); }
}



##################################################################################################################################################################
##################################################################################################################################################################
# make "parcel-average timecourses" of some of the STATS fields 
# input images are 81x96x81

do.parcelavg.vol <- function(sub.id, sess.id, do.ON_BLOCKS=TRUE, do.ON_MIXED=TRUE, do.ON_MIXED_CUE=TRUE, 
                             do.ON_TRIALS=TRUE, do.CongruencyCW=TRUE) {
  # sub.id <- "SCW994"; sess.id <- "Bas"; do.ON_BLOCKS <- TRUE; do.ON_MIXED <- TRUE; do.ON_MIXED_CUE <- TRUE; do.ON_TRIALS <- TRUE; do.CongruencyCW <- TRUE;
  
  was.success <- TRUE;   # initialize return value 
  
  # get full name in output directories, for consistency with DMCC
  if (sess.id == "Bas") { session.id <- "baseline"; }
  if (sess.id == "Pro") { session.id <- "proactive"; }
  if (sess.id == "Rea") { session.id <- "reactive"; }
  # needed input files vary with which GLM(s) to make timecourses for, so check each individually.
  
  
  
  # # # # # # ON_BLOCKS GLM: volume # # # # # #
  if (do.ON_BLOCKS == TRUE & was.success == TRUE) {
    fnameON2 <- paste0(in.path, "DATA/AFNI_ANALYSIS/", sub.id, "/RESULTS/", session.id, "_ON_BLOCKS/STATS_", sub.id, "_REML.nii.gz");   # input
    fname2 <- paste0(in.path, "DATA/AFNI_ANALYSIS/", sub.id, "/RESULTS/", session.id, "_ON_BLOCKS/", sub.id, "_ON_BLOCKS#0_Coef_Schaefer2018_400x7_vol.txt");  # output
    if (file.exists(fnameON2) & !file.exists(fname2)) {   # proceed
      all.lbls <- system2(paste0(afni.path, "3dinfo"), args=paste0("-label ", fnameON2), stdout=TRUE);
      all.lbls <- strsplit(all.lbls, "[|]")[[1]];   # need [|] since | is a special character
      if (length(all.lbls) != 4) { stop("ERROR: ON_BLOCKS length(all.lbls) != 4"); }
      
      for (do.par in c("subcortical", "Schaefer2018_400x7")) {    # do.par <- "subcortical";  # do.par <- "Schaefer2018_400x7"
        p.fname <- paste0(p.path, do.par, "_StroopCW.nii.gz");  # parcellation image
        
        # no TENTs
        for (lbl in c("Full_Fstat", "ON_BLOCKS#0_Coef", "ON_BLOCKS#0_Tstat")) {     # lbl <- "Full_Fstat";
          out.fname <- paste0(in.path, "DATA/AFNI_ANALYSIS/", sub.id, "/RESULTS/", session.id, "_ON_BLOCKS/", sub.id, "_", lbl,"_", do.par, "_vol.txt");
          brick.num <- which(all.lbls %in% lbl)-1;  # index of the lbl (-1 since afni 0-based)
          if (!is.na(brick.num) & !file.exists(out.fname)) {
            system2(paste0(afni.path, "3dROIstats"),
                    args=paste0("-mask ", p.fname, " ", fnameON2, "[", brick.num, "] > ", out.fname), stdout=TRUE);
          }
        }
      }
    } else {   # not right mix of files to start
      if (!file.exists(fnameON2)) {
        print(paste0("ERROR: ", session.id, "_ON_BLOCKS/STATS_", sub.id, "_REML.nii.gz not found but do.ON_BLOCKS=TRUE")); 
        was.success <- FALSE; 
      }
      if (file.exists(fname2)) {
        print(paste0("ERROR: ", session.id, "_ON_BLOCKS/", sub.id, "_ON_BLOCKS#0_Coef_Schaefer2018_400x7_vol.txt found but do.ON_BLOCKS=TRUE")); 
        was.success <- FALSE; 
      }
    }
  }
  
  
  
  # # # # # # ON_MIXED_CUE GLM: volume # # # # # #
  if (do.ON_MIXED_CUE == TRUE & was.success == TRUE) {
    fnameON4 <- paste0(in.path, "DATA/AFNI_ANALYSIS/", sub.id, "/RESULTS/", session.id, "_ON_MIXED_CUE/STATS_", sub.id, "_REML.nii.gz");   # input
    fname4 <- paste0(in.path, "DATA/AFNI_ANALYSIS/", sub.id, "/RESULTS/", session.id, "_ON_MIXED_CUE/", sub.id, "_ON_TRIALS_Schaefer2018_400x7_vol.txt");  # output
    if (file.exists(fnameON4) & !file.exists(fname4)) {   # proceed
      all.lbls <- system2(paste0(afni.path, "3dinfo"), args=paste0("-label ", fnameON4), stdout=TRUE);
      all.lbls <- strsplit(all.lbls, "[|]")[[1]];   # need [|] since | is a special character
      if (length(all.lbls) != 34) { stop("ERROR: ON_MIXED_CUE length(all.lbls) != 34"); }
      
      # we want the 13 _Coefs for the ON_TRIALS, plus the cue & Full_Fstat.
      for (do.par in c("subcortical", "Schaefer2018_400x7")) {    # do.par <- "subcortical";  # do.par <- "Schaefer2018_400x7"
        p.fname <- paste0(p.path, do.par, "_StroopCW.nii.gz");  # parcellation image
        
        # first Full_Fstat
        for (lbl in c("Full_Fstat", "cue#0_Coef", "cue#0_Tstat", "ON_BLOCKS#0_Coef", "ON_BLOCKS#0_Tstat")) {    # lbl <- "cue#0_Coef";
          out.fname <- paste0(in.path, "DATA/AFNI_ANALYSIS/", sub.id, "/RESULTS/", session.id, "_ON_MIXED_CUE/", sub.id, "_", lbl,"_", do.par, "_vol.txt");
          brick.num <- which(all.lbls %in% lbl)-1;  # index of the lbl (-1 since afni 0-based)
          if (!is.na(brick.num) & !file.exists(out.fname)) {
            system2(paste0(afni.path, "3dROIstats"),
                    args=paste0("-mask ", p.fname, " ", fnameON4, "[", brick.num, "] > ", out.fname), stdout=TRUE);
          }
        }
        
        # now all the TENTs
        lbl <- "ON_TRIALS";
        out.fname <- paste0(in.path, "DATA/AFNI_ANALYSIS/", sub.id, "/RESULTS/", session.id, "_ON_MIXED_CUE/", sub.id, "_", lbl,"_", do.par, "_vol.txt");
        lbls <- paste0(lbl, "#", 0:12, "_Coef");   # full sub-brick names
        brick.nums <- paste0((which(all.lbls %in% lbls)-1), collapse=",");  # index of each lbls (-1 since afni 0-based)
        if (nchar(brick.nums) > 12 & !file.exists(out.fname)) {
          system2(paste0(afni.path, "3dROIstats"),
                  args=paste0("-longnames -mask ", p.fname, " '", fnameON4, "[", brick.nums, "]' > ", out.fname), stdout=TRUE);
        }
      }
    } else {   # not right mix of files to start
      if (!file.exists(fnameON4)) {
        print(paste0("ERROR: ", session.id, "_ON_MIXED_CUE/STATS_", sub.id, "_REML.nii.gz not found but do.ON_MIXED_CUE=TRUE")); was.success <- FALSE; }
      if (file.exists(fname4)) {
        print(paste0("ERROR: ", session.id, "_ON_MIXED_CUE/", sub.id, "_ON_TRIALS_Schaefer2018_400x7_vol.txt found but do.ON_MIXED_CUE=TRUE")); 
        was.success <- FALSE; 
      }
    }
  }
  
  
  
  # # # # # # ON_MIXED GLM: volume # # # # # #
  if (do.ON_MIXED == TRUE & was.success == TRUE) {
    fnameON3 <- paste0(in.path, "DATA/AFNI_ANALYSIS/", sub.id, "/RESULTS/", session.id, "_ON_MIXED/STATS_", sub.id, "_REML.nii.gz");   # input
    fname3 <- paste0(in.path, "DATA/AFNI_ANALYSIS/", sub.id, "/RESULTS/", session.id, "_ON_MIXED/", sub.id, "_ON_TRIALS_Schaefer2018_400x7_vol.txt");  # output
    if (file.exists(fnameON3) & !file.exists(fname3)) {   # proceed
      all.lbls <- system2(paste0(afni.path, "3dinfo"), args=paste0("-label ", fnameON3), stdout=TRUE);
      all.lbls <- strsplit(all.lbls, "[|]")[[1]];   # need [|] since | is a special character
      if (length(all.lbls) != 58) { stop("ERROR: ON_MIXED length(all.lbls) != 58"); }
      
      # we want the 13 _Coefs for the ON_TRIALS & ON_blockCUEandOFF regressors, plus the Full_Fstat.
      for (do.par in c("subcortical", "Schaefer2018_400x7")) {    # do.par <- "subcortical";  # do.par <- "Schaefer2018_400x7"
        p.fname <- paste0(p.path, do.par, "_StroopCW.nii.gz");  # parcellation image
        
        # first Full_Fstat
        for (lbl in c("Full_Fstat", "ON_BLOCKS#0_Coef", "ON_BLOCKS#0_Tstat")){
          out.fname <- paste0(in.path, "DATA/AFNI_ANALYSIS/", sub.id, "/RESULTS/", session.id, "_ON_MIXED/", sub.id, "_", lbl,"_", do.par, "_vol.txt");
          #brick.num <- as.numeric(system2(paste0(afni.path, "3dinfo"), args=paste0("-label2index ", lbl, " ", fnameONs), stdout=TRUE));
          brick.num <- which(all.lbls %in% lbl)-1;  # index of the lbl (-1 since afni 0-based)
          if (!is.na(brick.num) & !file.exists(out.fname)) {
            system2(paste0(afni.path, "3dROIstats"),
                    args=paste0("-mask ", p.fname, " ", fnameON3, "[", brick.num, "] > ", out.fname), stdout=TRUE);
          }
        }
        # now all the TENTs
        for (lbl in c("ON_blockCUEandOFF", "ON_TRIALS")) {    #lbl <- "ON_TRIALS";
          out.fname <- paste0(in.path, "DATA/AFNI_ANALYSIS/", sub.id, "/RESULTS/", session.id, "_ON_MIXED/", sub.id, "_", lbl,"_", do.par, "_vol.txt");
          lbls <- paste0(lbl, "#", 0:12, "_Coef");   # full sub-brick names
          brick.nums <- paste0((which(all.lbls %in% lbls)-1), collapse=",");  # index of each lbls (-1 since afni 0-based)
          if (nchar(brick.nums) > 12 & !file.exists(out.fname)) {
            system2(paste0(afni.path, "3dROIstats"),
                    args=paste0("-longnames -mask ", p.fname, " '", fnameON3, "[", brick.nums, "]' > ", out.fname), stdout=TRUE);
          }
        }
      }
    } else {   # not right mix of files to start
      if (!file.exists(fnameON3)) {
        print(paste0("ERROR: ", session.id, "_ON_MIXED/STATS_", sub.id, "_REML.nii.gz not found but do.ON_MIXED=TRUE")); was.success <- FALSE; }
      if (file.exists(fname3)) {
        print(paste0("ERROR: ", session.id, "_ON_MIXED/", sub.id, "_ON_TRIALS_Schaefer2018_400x7_vol.txt found but do.ON_MIXED=TRUE")); 
        was.success <- FALSE; 
      }
    }
  }
  
  
  
  # # # # # # ON_TRIALS GLM: volume # # # # # #
  if (do.ON_TRIALS == TRUE & was.success == TRUE) {
    fnameON1 <- paste0(in.path, "DATA/AFNI_ANALYSIS/", sub.id, "/RESULTS/", session.id, "_ON_TRIALS/STATS_", sub.id, "_REML.nii.gz");   # input
    fname1 <- paste0(in.path, "DATA/AFNI_ANALYSIS/", sub.id, "/RESULTS/", session.id, "_ON_TRIALS/", sub.id, "_ON_TRIALS_Schaefer2018_400x7_vol.txt");  # output
    if (file.exists(fnameON1) & !file.exists(fname1)) {   # proceed
      all.lbls <- system2(paste0(afni.path, "3dinfo"), args=paste0("-label ", fnameON1), stdout=TRUE);
      all.lbls <- strsplit(all.lbls, "[|]")[[1]];   # need [|] since | is a special character
      if (length(all.lbls) != 28) { stop("ERROR: ON_TRIALS length(all.lbls) != 28"); }
      
      # we want the 13 _Coefs for the ON_TRIALS regressor, plus the Full_Fstat.
      for (do.par in c("subcortical", "Schaefer2018_400x7")) {    # do.par <- "subcortical";  # do.par <- "Schaefer2018_400x7"
        p.fname <- paste0(p.path, do.par, "_StroopCW.nii.gz");  # parcellation image
        
        # first Full_Fstat
        lbl <- "Full_Fstat";
        out.fname <- paste0(in.path, "DATA/AFNI_ANALYSIS/", sub.id, "/RESULTS/", session.id, "_ON_TRIALS/", sub.id, "_", lbl,"_", do.par, "_vol.txt");
        #brick.num <- as.numeric(system2(paste0(afni.path, "3dinfo"), args=paste0("-label2index ", lbl, " ", fnameONs), stdout=TRUE));
        brick.num <- which(all.lbls %in% lbl)-1;  # index of the lbl (-1 since afni 0-based)
        if (!is.na(brick.num) & !file.exists(out.fname)) {
          system2(paste0(afni.path, "3dROIstats"),
                  args=paste0("-mask ", p.fname, " ", fnameON1, "[", brick.num, "] > ", out.fname), stdout=TRUE);
        }
        
        # now all the TENTs
        lbl <- "ON_TRIALS";
        out.fname <- paste0(in.path, "DATA/AFNI_ANALYSIS/", sub.id, "/RESULTS/", session.id, "_ON_TRIALS/", sub.id, "_", lbl,"_", do.par, "_vol.txt");
        lbls <- paste0(lbl, "#", 0:12, "_Coef");   # full sub-brick names
        brick.nums <- paste0((which(all.lbls %in% lbls)-1), collapse=",");  # index of each lbls (-1 since afni 0-based)
        if (nchar(brick.nums) > 12 & !file.exists(out.fname)) {
          system2(paste0(afni.path, "3dROIstats"),
                  args=paste0("-longnames -mask ", p.fname, " '", fnameON1, "[", brick.nums, "]' > ", out.fname), stdout=TRUE);
        }
      }
    } else {   # not right mix of files to start
      if (!file.exists(fnameON1)) {
        print(paste0("ERROR: ", session.id, "_ON_TRIALS/STATS_", sub.id, "_REML.nii.gz not found but do.ON_TRIALS=TRUE")); was.success <- FALSE; }
      if (file.exists(fname1)) {
        print(paste0("ERROR: ", session.id, "_ON_TRIALS/", sub.id, "_ON_TRIALS_Schaefer2018_400x7_vol.txt found but do.ON_TRIALS=TRUE")); 
        was.success <- FALSE; 
      }
    }
  }
  
  
  
  # # # # # # CongruencyCW GLM: volume # # # # # #
  if (do.CongruencyCW == TRUE & was.success == TRUE) {
    fnameSTATS <- paste0(in.path, "DATA/AFNI_ANALYSIS/", sub.id, "/RESULTS/", session.id, "_CongruencyCW/STATS_", sub.id, "_REML.nii.gz");   # input
    fname1 <- paste0(in.path, "DATA/AFNI_ANALYSIS/", sub.id, "/RESULTS/", session.id, "_CongruencyCW/", sub.id, "_C_W_block#0_Coef_Schaefer2018_400x7_vol.txt");  # output
    if (file.exists(fnameSTATS) & !file.exists(fname1)) {   # proceed
      all.lbls <- system2(paste0(afni.path, "3dinfo"), args=paste0("-label ", fnameSTATS), stdout=TRUE);
      all.lbls <- strsplit(all.lbls, "[|]")[[1]];   # need [|] since | is a special character
      # Rea CongruencyCW (only) has buffConC and buffConW regressors, so the expected length varies with session
      if (sess.id == "Rea") { need.len <- 550; } else { need.len <- 496; }
      if (length(all.lbls) != need.len) { stop(paste("ERROR: CongruencyCW length(all.lbls) !=", need.len)); }
      
      for (do.par in c("subcortical", "Schaefer2018_400x7")) {    # do.par <- "subcortical";  # do.par <- "Schaefer2018_400x7"
        p.fname <- paste0(p.path, do.par, "_StroopCW.nii.gz");  # parcellation image
        
        # first not-TENTs
        for (lbl in c("Full_Fstat", "blockC#0_Coef", "blockC#0_Tstat", "blockW#0_Coef", "blockW#0_Tstat",
                      "C_W_block#0_Coef", "C_W_block#0_Tstat")) {     # lbl <- "Full_Fstat";
          out.fname <- paste0(in.path, "DATA/AFNI_ANALYSIS/", sub.id, "/RESULTS/", session.id, "_CongruencyCW/", sub.id, "_", lbl,"_", do.par, "_vol.txt");
          brick.num <- which(all.lbls %in% lbl)-1;  # index of the lbl (-1 since afni 0-based)
          if (!is.na(brick.num) & !file.exists(out.fname)) {
            system2(paste0(afni.path, "3dROIstats"),
                    args=paste0("-mask ", p.fname, " ", fnameSTATS, "[", brick.num, "] > ", out.fname), stdout=TRUE);
          }
        }
        
        # now the TENTs
        lbl.vec <- c("blockCUEandOFF", "PC50ConC", "PC50ConW", "PC50InConC", "PC50InConW", "biasConC", "biasConW", "biasInConC",
                  "biasInConW", "InCon_Con_biasC", "InCon_Con_biasW", "InCon_Con_PC50C", "InCon_Con_PC50W", "InCon_Con_PC50biasC",
                  "InCon_Con_PC50biasW", "C_W_InCon", "C_W_biasInCon", "C_W_PC50InCon");  # for all three sessions
        if (sess.id == "Rea") { lbl.vec <- c(lbl.vec, "buffConC", "buffConW"); }  # only reactive
          
        for (lbl in lbl.vec) {    # lbl <- lbl.vec[14];
          out.fname <- paste0(in.path, "DATA/AFNI_ANALYSIS/", sub.id, "/RESULTS/", session.id, "_CongruencyCW/", sub.id, "_", lbl,"_", do.par, "_vol.txt");
          lbls <- paste0(lbl, "#", 0:12, "_Coef");   # full sub-brick names
          brick.nums <- paste0((which(all.lbls %in% lbls)-1), collapse=",");  # index of each lbls (-1 since afni 0-based)
          if (nchar(brick.nums) > 12 & !file.exists(out.fname)) {
            system2(paste0(afni.path, "3dROIstats"),
                    args=paste0("-longnames -mask ", p.fname, " '", fnameSTATS, "[", brick.nums, "]' > ", out.fname), stdout=TRUE);
          }
        }
      }
    } else {   # not right mix of files to start
      if (!file.exists(fnameSTATS)) {
        print(paste0("ERROR: ", session.id, "_CongruencyCW/STATS_", sub.id, "_REML.nii.gz not found but do.CongruencyCW=TRUE")); was.success <- FALSE; }
      if (file.exists(fname1)) {
        print(paste0("ERROR: ", session.id, "_CongruencyCW/", sub.id, "_C_W_block#0_Coef_Schaefer2018_400x7_vol.txt found but do.CongruencyCW=TRUE")); 
        was.success <- FALSE; 
      }
    }
  }
  
  
  if (was.success) { print(paste("do.parcelavg.vol", sess.id, "finished successfully!")); }
}


##################################################################################################################################################################
# done
##################################################################################################################################################################









