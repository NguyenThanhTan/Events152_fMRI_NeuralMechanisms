# fMRI152 (naturalistic stimuli watching) GLMs: volumes
# started 21 April 2023 by Tan. Adapted from /data/nil-bluearc/ccp-hcp/StroopCW/CODE/GLMcode/GLMs_vol.R
# EVTs made with afni_events_from_segmentation.ipynb

# TENT(-10, 10, 11) as recommended by Jo.  -> should be TENT, not TENTzero.

###############################################################################################################################################################
###############################################################################################################################################################

# in.path <- "/data/nil-bluearc/ccp-hcp/StroopCW/";  
in.path <- "/data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/voxelwiseAnalyses/finite_impulse_response/";
afni.path <- "/usr/local/pkg/afni_22/";   # path to the ccplinux1 afni function executables
# afni.path <- "/usr/local/pkg/afni/";   # path to the penfield afni function executables
# p.path <- "/data/nil-bluearc/ccp-hcp/StroopCW/ATLASES/";   # parcellations
p.path <- "/data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/voxelwiseAnalyses/atlas/"

# the do. parameters control if running the corresponding GLM is attempted; e.g., to skip do.COARSE, set do.COARSE=FALSE.
do.GLMs.vol <- function(sub.id, do.ON_FINE=TRUE, do.ON_COARSE=TRUE, do.ON_BOTH=TRUE) {     
  # sub.id <- "sub-02"; do.ON_FINE <- TRUE; ...
  print(paste("Start running GLMs volume for subject", sub.id))
  was.success <- TRUE;   # initialize return value 
  
  evt.path <- paste0(in.path, "EVTs/", sub.id, "/"); # to shorten paths later
  
  
  # check for input files needed for all the GLMs
  c.fname <- paste0(in.path, "AFNI_ANALYSIS/", sub.id, "/INPUT_DATA/", sub.id, "_movie_FD_mask.txt");     # 0 1 $censor_file
  if (!file.exists(c.fname)) { print(paste("ERROR: didn't find censor file", c.fname)); was.success <- FALSE; }
  
  mot.fname <- paste0(in.path, "AFNI_ANALYSIS/", sub.id, "/INPUT_DATA/", sub.id, "_movie_6regressors_demean.txt");  # ${motion_file}
  if (!file.exists(mot.fname)) { print(paste("ERROR: didn't find mot file", mot.fname)); was.success <- FALSE; }
  
  
  ## Need Jo's check here!!
  # for the task analyses I'm used to, we only run the GLMs if more than half the data is present and usable.
  # Here, you either have (or not) entire runs; you don't have any partial runs; people with at least two runs should be ok.

  # and the bold runs; need at least two. I have some not-very-elegant code for parsing the filename combinations but will skip for now.
  bold1.fname <- paste0(in.path, "AFNI_ANALYSIS/", sub.id, "/INPUT_DATA/lpi_scale_blur6_", 
                        sub.id, "_task-movie_run-1_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz");
  bold2.fname <- paste0(in.path, "AFNI_ANALYSIS/", sub.id, "/INPUT_DATA/lpi_scale_blur6_",
                        sub.id, "_task-movie_run-2_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz");
  bold3.fname <- paste0(in.path, "AFNI_ANALYSIS/", sub.id, "/INPUT_DATA/lpi_scale_blur6_",
                        sub.id, "_task-movie_run-3_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz");
  bold4.fname <- paste0(in.path, "AFNI_ANALYSIS/", sub.id, "/INPUT_DATA/lpi_scale_blur6_",
                        sub.id, "_task-movie_run-4_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz");
  
  # strings to hold the bold filenames; slightly different syntax for the two afni commands
  if (file.exists(bold1.fname) & file.exists(bold2.fname) & file.exists(bold3.fname) & file.exists(bold4.fname)) { 
    # input.str.decon <- paste0("-input '", bold1.fname, "' '", bold2.fname, "'");
    input.str.decon <- paste0("-input '", bold1.fname, "' '", bold2.fname, "' '", bold3.fname, "' '", bold4.fname, "'");
    # input.str.reml  <- paste0('-input "', bold1.fname, " ", bold2.fname, '"');
    input.str.reml  <- paste0('-input "', bold1.fname, " ", bold2.fname, " ", bold3.fname, " ", bold4.fname, '"');
  } else {
    input.str.decon <- "";
    input.str.reml <- "";
    print("didn't find one or both bold.nii.gz"); 
    was.success <- FALSE;
  }
  # rm(bold1.fname, bold2.fname);  # cleanup
  rm(bold1.fname, bold2.fname, bold3.fname, bold4.fname);  # cleanup
  
  # and check for previous output - afni won't overwrite, so stop if find files
  # I've made a more efficient way of doing this bit, but you can also just omit and watch for afni errors;
  # I put this in mostly for the RAs, to try to have somewhat sensible error messages.
  
  fname1 <- paste0(in.path, "AFNI_ANALYSIS/", sub.id, "/RESULTS/ON_FINE/STATS_", sub.id, "_REML.nii.gz");
  if (do.ON_FINE == TRUE & file.exists(fname1)) {
    print(paste0("ERROR: /RESULTS/ON_FINE/STATS_", sub.id, "_REML.nii.gz already exists but do.ON_FINE=TRUE."));
    was.success <- FALSE;
  }
  
  # fname2 <- paste0(in.path, "DATA/AFNI_ANALYSIS/", sub.id, "/RESULTS/", session.id, "_ON_BLOCKS/STATS_", sub.id, "_REML.nii.gz");  
  # if (do.ON_BLOCKS == TRUE & file.exists(fname2)) { 
  #   print(paste0("ERROR: /RESULTS/", session.id, "_ON_BLOCKS/STATS_", sub.id, "_REML.nii.gz already exists but do.ON_BLOCKS=TRUE.")); 
  #   was.success <- FALSE; 
  # }
  fname2 <- paste0(in.path, "AFNI_ANALYSIS/", sub.id, "/RESULTS/ON_COARSE/STATS_", sub.id, "_REML.nii.gz");
  if (do.ON_COARSE == TRUE & file.exists(fname2)) {
    print(paste0("ERROR: /RESULTS/ON_COARSE/STATS_", sub.id, "_REML.nii.gz already exists but do.ON_COARSE=TRUE."));
    was.success <- FALSE;
  }
  
  # fname3 <- paste0(in.path, "DATA/AFNI_ANALYSIS/", sub.id, "/RESULTS/", session.id, "_ON_MIXED/STATS_", sub.id, "_REML.nii.gz");  
  # if (do.ON_MIXED == TRUE & file.exists(fname3)) { 
  #   print(paste0("ERROR: /RESULTS/", session.id, "_ON_MIXED/STATS_", sub.id, "_REML.nii.gz already exists but do.ON_MIXED=TRUE.")); 
  #   was.success <- FALSE; 
  # }
  fname3 <- paste0(in.path, "AFNI_ANALYSIS/", sub.id, "/RESULTS/ON_BOTH/STATS_", sub.id, "_REML.nii.gz");
  if (do.ON_BOTH == TRUE & file.exists(fname3)) {
    print(paste0("ERROR: /RESULTS/ON_BOTH/STATS_", sub.id, "_REML.nii.gz already exists but do.ON_MIXED=TRUE."));
    was.success <- FALSE;
  }

  
  if (was.success == TRUE) {    # so far, so good, so keep going
    out.path <- paste0(in.path, "AFNI_ANALYSIS/", sub.id, "/RESULTS/");
    if (!dir.exists(out.path)) { dir.create(out.path); }   # make the top-level output directory if needed
    
    # # this is closest to what I want to be able to run fine and coarse boundaries together
    # # # # # # # ON_MIXED GLM: volume # # # # # # 
    # # BLOCK(3,1) for cue since cue is shown for 3 seconds.
    # if (do.ON_MIXED == TRUE) {
    #   # make the output directories
    #   out.path <- paste0(in.path, "DATA/AFNI_ANALYSIS/", sub.id, "/RESULTS/", session.id, "_ON_MIXED/");  # actual output directory
    #   if (!dir.exists(out.path)) { dir.create(out.path); }
    #   setwd(out.path);  # needed for afni to write files in proper directory
      
    #   # call AFNI to do the GLM
    #   system2(paste0(afni.path, "3dDeconvolve"),
    #           args=paste0("-local_times -x1D_stop -GOFORIT 5 ", input.str.decon, " -polort A -float ",
    #                       "-censor ", c.fname, " -num_stimts 3 ",
    #                       "-stim_times_AM1 1 ", evt.path, sub.id, "_StroopCW_", session.id, "_block.txt 'dmBLOCK(1)' -stim_label 1 ON_BLOCKS ",
    #                       "-stim_times 2 ", evt.path, sub.id, "_StroopCW_", session.id, "_blockCUEandOFF.txt 'TENTzero(0,16.8,15)' -stim_label 2 ON_blockCUEandOFF ",
    #                       "-stim_times 3 ", evt.path, sub.id, "_StroopCW_", session.id, "_allTrials.txt 'TENTzero(0,16.8,15)' -stim_label 3 ON_TRIALS ",
    #                       "-ortvec ", mot.fname, " motion -x1D X.xmat.1D -xjpeg X.jpg -nobucket"), stdout=TRUE);
      
    #   system2(paste0(afni.path, "3dREMLfit"), args=paste0("-matrix X.xmat.1D -GOFORIT 5 ", input.str.reml, " ",
    #                                                       "-Rvar stats_var_", sub.id, "_REML.nii.gz ",
    #                                                       "-Rbuck STATS_", sub.id, "_REML.nii.gz ",
    #                                                       "-fout -tout -nobout -verb"), stdout=TRUE);
    # }
    
    # adapted from do.ON_MIXED  .... ON_TRIALS is actually closer to what you need; you don't have anything like BLOCKS or cue.
    if (do.ON_BOTH == TRUE) {
      print("Running for do.ON_BOTH")
      # make the output directories
      out.path <- paste0(in.path, "AFNI_ANALYSIS/", sub.id, "/RESULTS/ON_BOTH/");  # actual output directory
      if (!dir.exists(out.path)) { dir.create(out.path); }
      setwd(out.path);  # needed for afni to write files in proper directory
      
      # call AFNI to do the GLM

      ##### Need Jo's check here!!
      system_output <- system2(paste0(afni.path, "3dDeconvolve"),
              args=paste0("-local_times -x1D_stop -GOFORIT 5 ", input.str.decon, " -polort A -float ",
                          # "-censor ", c.fname, " -num_stimts 3 ",
                          "-censor ", c.fname, " -num_stimts 2 ",
                          # AM is amplitude modulated, the format of _block.txt is time:amplitude pair, seem not relevant here.
                          # "-stim_times_AM1 1 ", evt.path, sub.id, "_StroopCW_", session.id, "_block.txt 'dmBLOCK(1)' -stim_label 1 ON_BLOCKS ",
                          # "-stim_times 2 ", evt.path, sub.id, "_StroopCW_", session.id, "_cue.txt 'BLOCK(3,1)' -stim_label 2 cue ",
                          # "-stim_times 3 ", evt.path, sub.id, "_StroopCW_", session.id, "_allTrials.txt 'TENTzero(0,16.8,15)' -stim_label 3 ON_TRIALS ",
                          "-stim_times 1 ", evt.path, sub.id, "_movie_fine.txt 'TENT(-10,10,11)' -stim_label 1 ON_FINE ",
                          "-stim_times 2 ", evt.path, sub.id, "_movie_coarse.txt 'TENT(-10,10,11)' -stim_label 2 ON_COARSE ",
                          "-ortvec ", mot.fname, " motion -x1D X.xmat.1D -xjpeg X.jpg -nobucket"), 
                          stdout=TRUE, stderr=TRUE);
      cat(system_output, sep = "\n")
      
      system_output <- system2(paste0(afni.path, "3dREMLfit"), args=paste0("-matrix X.xmat.1D -GOFORIT 5 ", input.str.reml, " ",
                                                          "-Rvar stats_var_", sub.id, "_REML.nii.gz ",
                                                          "-Rbuck STATS_", sub.id, "_REML.nii.gz ",
                                                          "-fout -tout -nobout -verb"), 
                                                          stdout=TRUE, stderr=TRUE);
      cat(system_output, sep = "\n")
    }

    # # this is closest to what I want to run fine or coarse independently
    # # # # # # # ON_TRIALS GLM: volume # # # # # # 
    # if (do.ON_TRIALS == TRUE) {
    #   # make the output directories
    #   out.path <- paste0(in.path, "DATA/AFNI_ANALYSIS/", sub.id, "/RESULTS/", session.id, "_ON_TRIALS/");  # actual output directory
    #   if (!dir.exists(out.path)) { dir.create(out.path); }
    #   setwd(out.path);  # needed for afni to write files in proper directory
      
    #   # call AFNI to do the GLM
    #   system2(paste0(afni.path, "3dDeconvolve"),
    #           args=paste0("-local_times -x1D_stop -GOFORIT 5 ", input.str.decon, " -polort A -float ",
    #                       "-censor ", c.fname, " -num_stimts 1 ",
    #                       "-stim_times 1 ", evt.path, sub.id, "_StroopCW_", session.id, "_allTrials.txt 'TENTzero(0,16.8,15)' -stim_label 1 ON_TRIALS ",
    #                       "-ortvec ", mot.fname, " motion -x1D X.xmat.1D -xjpeg X.jpg -nobucket"), stdout=TRUE);
      
    #   system2(paste0(afni.path, "3dREMLfit"), args=paste0("-matrix X.xmat.1D -GOFORIT 5 ", input.str.reml, " ",
    #                                                       "-Rvar stats_var_", sub.id, "_REML.nii.gz ",
    #                                                       "-Rbuck STATS_", sub.id, "_REML.nii.gz ",
    #                                                       "-fout -tout -nobout -verb"), stdout=TRUE);
    # }
    
    ## Need Jo's check here!!
    # # # # # # ON_FINE GLM: volume # # # # # # 
    # adapted from do.ON_TRIALS
    if (do.ON_FINE == TRUE) {
      print("Running for do.ON_FINE")
      # make the output directories
      out.path <- paste0(in.path, "AFNI_ANALYSIS/", sub.id, "/RESULTS/ON_FINE/");  # actual output directory
      if (!dir.exists(out.path)) { dir.create(out.path); }
      setwd(out.path);  # needed for afni to write files in proper directory
      
      # call AFNI to do the GLM
      # note that afni output is stderr, not stdout!
      system_output <- system2(paste0(afni.path, "3dDeconvolve"),
              args=paste0("-local_times -x1D_stop -GOFORIT 5 ", input.str.decon, " -polort A -float ",
                          "-censor ", c.fname, " -num_stimts 1 ",
                          # "-stim_times 1 ", evt.path, sub.id, "_StroopCW_", session.id, "_allTrials.txt 'TENTzero(0,16.8,15)' -stim_label 1 ON_TRIALS ",
                          "-stim_times 1 ", evt.path, sub.id, "_movie_fine.txt 'TENT(-10,10,11)' -stim_label 1 ON_FINE ",
                          "-ortvec ", mot.fname, " motion -x1D X.xmat.1D -xjpeg X.jpg -nobucket"), 
                          stdout=TRUE, stderr=TRUE);
      cat(system_output, sep = "\n")

      system_output <- system2(paste0(afni.path, "3dREMLfit"), args=paste0("-matrix X.xmat.1D -GOFORIT 5 ", input.str.reml, " ",
                                                          "-Rvar stats_var_", sub.id, "_REML.nii.gz ",
                                                          "-Rbuck STATS_", sub.id, "_REML.nii.gz ",
                                                          "-fout -tout -nobout -verb"), 
                                                          stdout=TRUE, stderr=TRUE);
      cat(system_output, sep = "\n")
    }

    ## Need Jo's check here!!
    # # # # # # ON_COARSE GLM: volume # # # # # # 
    # adapted from do.ON_TRIALS
    if (do.ON_COARSE == TRUE) {
      print("Running for do.ON_COARSE")
      # make the output directories
      out.path <- paste0(in.path, "AFNI_ANALYSIS/", sub.id, "/RESULTS/ON_COARSE/");  # actual output directory
      if (!dir.exists(out.path)) { dir.create(out.path); }
      setwd(out.path);  # needed for afni to write files in proper directory
      
      # call AFNI to do the GLM
      system_output <- system2(paste0(afni.path, "3dDeconvolve"),
              args=paste0("-local_times -x1D_stop -GOFORIT 5 ", input.str.decon, " -polort A -float ",
                          "-censor ", c.fname, " -num_stimts 1 ",
                          # "-stim_times 1 ", evt.path, sub.id, "_StroopCW_", session.id, "_allTrials.txt 'TENTzero(0,16.8,15)' -stim_label 1 ON_TRIALS ",
                          "-stim_times 1 ", evt.path, sub.id, "_movie_coarse.txt 'TENT(-10,10,11)' -stim_label 1 movie_coarse ",
                          "-ortvec ", mot.fname, " motion -x1D X.xmat.1D -xjpeg X.jpg -nobucket"), 
                          stdout=TRUE, stderr=TRUE);
      cat(system_output, sep = "\n")
      
      system_output <- system2(paste0(afni.path, "3dREMLfit"), args=paste0("-matrix X.xmat.1D -GOFORIT 5 ", input.str.reml, " ",
                                                          "-Rvar stats_var_", sub.id, "_REML.nii.gz ",
                                                          "-Rbuck STATS_", sub.id, "_REML.nii.gz ",
                                                          "-fout -tout -nobout -verb"), 
                                                          stdout=TRUE, stderr=TRUE);
      cat(system_output, sep = "\n")
    }
    
    # STATS didn't all exist before, so check if expected ones are present now
    # if (do.ON_TRIALS & !file.exists(fname1)) { was.success <- FALSE; }
    # if (do.ON_BLOCKS & !file.exists(fname2)) { was.success <- FALSE; }
    # if (do.ON_MIXED & !file.exists(fname3)) { was.success <- FALSE; }
    # if (do.ON_MIXED_CUE & !file.exists(fname4)) { was.success <- FALSE; }
    # if (do.CongruencyCW & !file.exists(fname5)) { was.success <- FALSE; }
    if (do.ON_FINE & !file.exists(fname1)) { was.success <- FALSE; }
    if (do.ON_COARSE & !file.exists(fname2)) { was.success <- FALSE; }
    if (do.ON_BOTH & !file.exists(fname3)) { was.success <- FALSE; }
  }
  
  if (was.success) { print(paste("do.GLMs.vol finished successfully!")); }
}


## Not adapted yet, seems like this is after running GLMs for all voxels.
##################################################################################################################################################################
##################################################################################################################################################################
# make "parcel-average timecourses" of some of the STATS fields 
# input images are 81x96x81

do.parcelavg.vol <- function(sub.id, do.ON_FINE=TRUE, do.ON_COARSE=TRUE, do.ON_BOTH=TRUE) {
  # sub.id <- "SCW994"; sess.id <- "Bas"; do.ON_BLOCKS <- TRUE; do.ON_MIXED <- TRUE; do.ON_MIXED_CUE <- TRUE; do.ON_TRIALS <- TRUE; do.CongruencyCW <- TRUE;
  # sub.id <- "sub-01"; do.ON_FINE=TRUE, do.ON_COARSE=TRUE, do.ON_BOTH=TRUE
  was.success <- TRUE;   # initialize return value 
  
  # get full name in output directories, for consistency with DMCC
  # if (sess.id == "Bas") { session.id <- "baseline"; }
  # if (sess.id == "Pro") { session.id <- "proactive"; }
  # if (sess.id == "Rea") { session.id <- "reactive"; }
  # needed input files vary with which GLM(s) to make timecourses for, so check each individually.

  
  
  
  # # # # # # # ON_MIXED GLM: volume # # # # # #
  # if (do.ON_MIXED == TRUE & was.success == TRUE) {
  #   fnameON3 <- paste0(in.path, "AFNI_ANALYSIS/", sub.id, "/RESULTS/", session.id, "_ON_MIXED/STATS_", sub.id, "_REML.nii.gz");   # input
  #   fname3 <- paste0(in.path, "AFNI_ANALYSIS/", sub.id, "/RESULTS/", session.id, "_ON_MIXED/", sub.id, "_ON_TRIALS_Schaefer2018_400x7_vol.txt");  # output
  #   if (file.exists(fnameON3) & !file.exists(fname3)) {   # proceed
  #     all.lbls <- system2(paste0(afni.path, "3dinfo"), args=paste0("-label ", fnameON3), stdout=TRUE);
  #     all.lbls <- strsplit(all.lbls, "[|]")[[1]];   # need [|] since | is a special character
  #     if (length(all.lbls) != 58) { stop("ERROR: ON_MIXED length(all.lbls) != 58"); }
      
  #     # we want the 13 _Coefs for the ON_TRIALS & ON_blockCUEandOFF regressors, plus the Full_Fstat.
  #     for (do.par in c("subcortical", "Schaefer2018_400x7")) {    # do.par <- "subcortical";  # do.par <- "Schaefer2018_400x7"
  #       p.fname <- paste0(p.path, do.par, "_StroopCW.nii.gz");  # parcellation image
        
  #       # first Full_Fstat
  #       for (lbl in c("Full_Fstat", "ON_BLOCKS#0_Coef", "ON_BLOCKS#0_Tstat")){
  #         out.fname <- paste0(in.path, "AFNI_ANALYSIS/", sub.id, "/RESULTS/", session.id, "_ON_MIXED/", sub.id, "_", lbl,"_", do.par, "_vol.txt");
  #         #brick.num <- as.numeric(system2(paste0(afni.path, "3dinfo"), args=paste0("-label2index ", lbl, " ", fnameONs), stdout=TRUE));
  #         brick.num <- which(all.lbls %in% lbl)-1;  # index of the lbl (-1 since afni 0-based)
  #         if (!is.na(brick.num) & !file.exists(out.fname)) {
  #           system2(paste0(afni.path, "3dROIstats"),
  #                   args=paste0("-mask ", p.fname, " ", fnameON3, "[", brick.num, "] > ", out.fname), stdout=TRUE);
  #         }
  #       }
  #       # now all the TENTs
  #       for (lbl in c("ON_blockCUEandOFF", "ON_TRIALS")) {    #lbl <- "ON_TRIALS";
  #         out.fname <- paste0(in.path, "AFNI_ANALYSIS/", sub.id, "/RESULTS/", session.id, "_ON_MIXED/", sub.id, "_", lbl,"_", do.par, "_vol.txt");
  #         lbls <- paste0(lbl, "#", 0:12, "_Coef");   # full sub-brick names
  #         brick.nums <- paste0((which(all.lbls %in% lbls)-1), collapse=",");  # index of each lbls (-1 since afni 0-based)
  #         if (nchar(brick.nums) > 12 & !file.exists(out.fname)) {
  #           system2(paste0(afni.path, "3dROIstats"),
  #                   args=paste0("-longnames -mask ", p.fname, " '", fnameON3, "[", brick.nums, "]' > ", out.fname), stdout=TRUE);
  #         }
  #       }
  #     }
  #   } else {   # not right mix of files to start
  #     if (!file.exists(fnameON3)) {
  #       print(paste0("ERROR: ", session.id, "_ON_MIXED/STATS_", sub.id, "_REML.nii.gz not found but do.ON_MIXED=TRUE")); was.success <- FALSE; }
  #     if (file.exists(fname3)) {
  #       print(paste0("ERROR: ", session.id, "_ON_MIXED/", sub.id, "_ON_TRIALS_Schaefer2018_400x7_vol.txt found but do.ON_MIXED=TRUE")); 
  #       was.success <- FALSE; 
  #     }
  #   }
  # }
  
  
  # # # # # # # ON_TRIALS GLM: volume # # # # # #
  # if (do.ON_TRIALS == TRUE & was.success == TRUE) {
  #   fnameON1 <- paste0(in.path, "AFNI_ANALYSIS/", sub.id, "/RESULTS/", session.id, "_ON_TRIALS/STATS_", sub.id, "_REML.nii.gz");   # input
  #   fname1 <- paste0(in.path, "AFNI_ANALYSIS/", sub.id, "/RESULTS/", session.id, "_ON_TRIALS/", sub.id, "_ON_TRIALS_Schaefer2018_400x7_vol.txt");  # output
  #   if (file.exists(fnameON1) & !file.exists(fname1)) {   # proceed
  #     all.lbls <- system2(paste0(afni.path, "3dinfo"), args=paste0("-label ", fnameON1), stdout=TRUE);
  #     all.lbls <- strsplit(all.lbls, "[|]")[[1]];   # need [|] since | is a special character
  #     if (length(all.lbls) != 28) { stop("ERROR: ON_TRIALS length(all.lbls) != 28"); }
      
  #     # we want the 13 _Coefs for the ON_TRIALS regressor, plus the Full_Fstat.
  #     for (do.par in c("subcortical", "Schaefer2018_400x7")) {    # do.par <- "subcortical";  # do.par <- "Schaefer2018_400x7"
  #       p.fname <- paste0(p.path, do.par, "_StroopCW.nii.gz");  # parcellation image
        
  #       # first Full_Fstat
  #       lbl <- "Full_Fstat";
  #       out.fname <- paste0(in.path, "AFNI_ANALYSIS/", sub.id, "/RESULTS/", session.id, "_ON_TRIALS/", sub.id, "_", lbl,"_", do.par, "_vol.txt");
  #       #brick.num <- as.numeric(system2(paste0(afni.path, "3dinfo"), args=paste0("-label2index ", lbl, " ", fnameONs), stdout=TRUE));
  #       brick.num <- which(all.lbls %in% lbl)-1;  # index of the lbl (-1 since afni 0-based)
  #       if (!is.na(brick.num) & !file.exists(out.fname)) {
  #         system2(paste0(afni.path, "3dROIstats"),
  #                 args=paste0("-mask ", p.fname, " ", fnameON1, "[", brick.num, "] > ", out.fname), stdout=TRUE);
  #       }
        
  #       # now all the TENTs
  #       lbl <- "ON_TRIALS";
  #       out.fname <- paste0(in.path, "AFNI_ANALYSIS/", sub.id, "/RESULTS/", session.id, "_ON_TRIALS/", sub.id, "_", lbl,"_", do.par, "_vol.txt");
  #       lbls <- paste0(lbl, "#", 0:12, "_Coef");   # full sub-brick names
  #       brick.nums <- paste0((which(all.lbls %in% lbls)-1), collapse=",");  # index of each lbls (-1 since afni 0-based)
  #       if (nchar(brick.nums) > 12 & !file.exists(out.fname)) {
  #         system2(paste0(afni.path, "3dROIstats"),
  #                 args=paste0("-longnames -mask ", p.fname, " '", fnameON1, "[", brick.nums, "]' > ", out.fname), stdout=TRUE);
  #       }
  #     }
  #   } else {   # not right mix of files to start
  #     if (!file.exists(fnameON1)) {
  #       print(paste0("ERROR: ", session.id, "_ON_TRIALS/STATS_", sub.id, "_REML.nii.gz not found but do.ON_TRIALS=TRUE")); was.success <- FALSE; }
  #     if (file.exists(fname1)) {
  #       print(paste0("ERROR: ", session.id, "_ON_TRIALS/", sub.id, "_ON_TRIALS_Schaefer2018_400x7_vol.txt found but do.ON_TRIALS=TRUE")); 
  #       was.success <- FALSE; 
  #     }
  #   }
  # }
  

  
  # # # # # # ON_BOTH GLM: volume # # # # # #
  ## adapted from ON_TRIALS, and ON_MIXED for the loop over labels
  if (do.ON_BOTH == TRUE & was.success == TRUE) {
    fnameON1 <- paste0(in.path, "AFNI_ANALYSIS/", sub.id, "/RESULTS/ON_BOTH/STATS_", sub.id, "_REML.nii.gz");   # input
    fname1 <- paste0(in.path, "AFNI_ANALYSIS/", sub.id, "/RESULTS/ON_BOTH/", sub.id, "_ON_BOTH_Schaefer2018_400x7_vol.txt");  # output
    if (file.exists(fnameON1) & !file.exists(fname1)) {   # proceed
      all.lbls <- system2(paste0(afni.path, "3dinfo"), args=paste0("-label ", fnameON1), stdout=TRUE);
      all.lbls <- strsplit(all.lbls, "[|]")[[1]];   # need [|] since | is a special character
      if (length(all.lbls) != 47) { stop("ERROR: ON_BOTH length(all.lbls) != 47"); }
      
      # we want the 22 (11 coarse, 11 fine) _Coefs for the ON_BOTH regressor, plus the Full_Fstat.
      for (do.par in c("TianSubcortexS2x3TMNI", "Schaefer2018_400x7")) {    # do.par <- "subcortical";  # do.par <- "Schaefer2018_400x7"
        # p.fname <- paste0(p.path, do.par, "_StroopCW.nii.gz");  # parcellation image
        p.fname <- paste0(p.path, do.par, "_94x111x94.nii.gz");  # parcellation image
        
        # first Full_Fstat
        lbl <- "Full_Fstat";
        out.fname <- paste0(in.path, "AFNI_ANALYSIS/", sub.id, "/RESULTS/ON_BOTH/", sub.id, "_", lbl,"_", do.par, "_vol.txt");
        #brick.num <- as.numeric(system2(paste0(afni.path, "3dinfo"), args=paste0("-label2index ", lbl, " ", fnameONs), stdout=TRUE));
        brick.num <- which(all.lbls %in% lbl)-1;  # index of the lbl (-1 since afni 0-based)
        if (!is.na(brick.num) & !file.exists(out.fname)) {
          system2(paste0(afni.path, "3dROIstats"),
                  args=paste0("-mask ", p.fname, " ", fnameON1, "[", brick.num, "] > ", out.fname), stdout=TRUE);
        }
        
        # now 11 Coefs for each of the two regressors
        for (lbl in c("ON_FINE", "ON_COARSE")) {
          out.fname <- paste0(in.path, "AFNI_ANALYSIS/", sub.id, "/RESULTS/ON_BOTH/", sub.id, "_", lbl, "_", do.par, "_vol.txt");
          lbls <- paste0(lbl, "#", 0:10, "_Coef");   # full sub-brick names
          brick.nums <- paste0((which(all.lbls %in% lbls)-1), collapse=",");  # index of each lbls (-1 since afni 0-based)
          if (nchar(brick.nums) >= 11 & !file.exists(out.fname)) {
            system2(paste0(afni.path, "3dROIstats"),
                    # note that -longnames seems to not exist in afni_19
                    args=paste0("-longnames -mask ", p.fname, " '", fnameON1, "[", brick.nums, "]' > ", out.fname), stdout=TRUE);
                    # args=paste0("-mask ", p.fname, " ", fnameON1, "[", brick.nums, "] > ", out.fname), stdout=TRUE);
          }
        }

      }
    } else {   # not right mix of files to start
      if (!file.exists(fnameON1)) {
        print(paste0("ERROR: ", "/RESULTS/ON_BOTH/STATS_", sub.id, "_REML.nii.gz not found but do.ON_BOTH=TRUE")); was.success <- FALSE; }
      if (file.exists(fname1)) {
        print(paste0("ERROR: ", "/RESULTS/ON_BOTH/STATS_", sub.id, "_ON_TRIALS_Schaefer2018_400x7_vol.txt found but do.ON_BOTH=TRUE")); 
        was.success <- FALSE; 
      }
    }
  }

  
  
  if (was.success) { print(paste("do.parcelavg.vol finished successfully!")); }
}


##################################################################################################################################################################
# done
##################################################################################################################################################################









