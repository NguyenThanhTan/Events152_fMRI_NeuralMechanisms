# fMRI152 (naturalistic stimuli watching) GLMs: volumes
# started 21 April 2023 by Tan. Adapted from /data/nil-bluearc/ccp-hcp/StroopCW/CODE/GLMcode/GLMs_vol.R
# EVTs made with afni_events_from_segmentation.ipynb

# 15 May 2023: Jo edited a bit to take out unused code, and to remove the do.ON_FINE, etc. flags. We always want all three run if both fine & coarse
# are present; only the one that is present if one is missing.
#### NEED to sort out runs with too much movement! Now, always uses all four runs; does not allow missings.
# TENT(-10,10,11) as recommended by Jo.  -> should be TENT, not TENTzero.


# 13 July 2023: switched to TENT(-10,20,16) at request of Jeff.
# FD 0.5 for the censoring threshold and criterion of dropping the run if more than 20% of the frames are censored, we'd drop:
# all four runs of sub10; sub11 runs 2 and 3; sub25 run1; sub42 run2. Change evts for sub25 & 42 to * for the affected runs.

###############################################################################################################################################################
###############################################################################################################################################################

in.path <- "/data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/voxelwiseAnalyses/finite_impulse_response/";
afni.path <- "/usr/local/pkg/afni_22/";   # path to the ccplinux1 afni function executables
# afni.path <- "/usr/local/pkg/afni/";   # path to the penfield afni function executables
p.path <- "/data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/voxelwiseAnalyses/atlas/"

do.GLMs.vol <- function(sub.id) {         # sub.id <- "sub-01";
  print(paste("Start running GLMs volume for subject", sub.id))
  was.success <- TRUE;   # initialize return value 
  
  # check for input files needed for all the GLMs
  c.fname <- paste0(in.path, "AFNI_ANALYSIS/", sub.id, "/INPUT_DATA/", sub.id, "_movie_FD_mask.txt");     # 0 1 $censor_file
  if (!file.exists(c.fname)) { print(paste("ERROR: didn't find censor file", c.fname)); was.success <- FALSE; }
  
  mot.fname <- paste0(in.path, "AFNI_ANALYSIS/", sub.id, "/INPUT_DATA/", sub.id, "_movie_6regressors_demean.txt");  # ${motion_file}
  if (!file.exists(mot.fname)) { print(paste("ERROR: didn't find mot file", mot.fname)); was.success <- FALSE; }
  
  # and the EVTs. evt files are present, but full of * when missing.
  evt.path <- paste0(in.path, "EVTs/", sub.id, "/"); # to shorten paths later
  fname <- paste0(evt.path, sub.id, "_movie_coarse.txt");
  if (file.exists(fname)) { 
    tmp <- readLines(fname); 
    if (length(tmp) == 4) {
      if (all.equal(tmp, rep("*", 4)) == TRUE) { do.coarse <- FALSE; } else { do.coarse <- TRUE; }
    } else { stop("invalid coarse EVT!"); }
  } else { stop("missing coarse EVT!"); }
  
  fname <- paste0(evt.path, sub.id, "_movie_fine.txt");
  if (file.exists(fname)) { 
    tmp <- readLines(fname); 
    if (length(tmp) == 4) {
      if (all.equal(tmp, rep("*", 4)) == TRUE) { do.fine <- FALSE; } else { do.fine <- TRUE; }
    } else { stop("invalid fine EVT!"); }
  } else { stop("missing fine EVT!"); }

  if (do.coarse == TRUE & do.fine == TRUE) { do.both <- TRUE; } else { do.both <- FALSE; }
  if (do.coarse == FALSE & do.fine == FALSE) { print("need coarse or fine EVTs"); was.success <- FALSE; }
  
  
  # for the task analyses I'm used to, we only run the GLMs if more than half the data is present and usable.
  # Here, you either have (or not) entire runs; you don't have any partial runs; people with at least two runs should be ok.
  
  # and the bold runs; need at least two. I have some not-very-elegant code for parsing the filename combinations but will skip for now.
  bold1.fname <- paste0(in.path, "AFNI_ANALYSIS/", sub.id, "/INPUT_DATA/lpi_scale_", 
                        sub.id, "_task-movie_run-1_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz");
  bold2.fname <- paste0(in.path, "AFNI_ANALYSIS/", sub.id, "/INPUT_DATA/lpi_scale_",
                        sub.id, "_task-movie_run-2_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz");
  bold3.fname <- paste0(in.path, "AFNI_ANALYSIS/", sub.id, "/INPUT_DATA/lpi_scale_",
                        sub.id, "_task-movie_run-3_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz");
  bold4.fname <- paste0(in.path, "AFNI_ANALYSIS/", sub.id, "/INPUT_DATA/lpi_scale_",
                        sub.id, "_task-movie_run-4_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz");
  
  
  # strings to hold the bold filenames; slightly different syntax for the two afni commands
  if (file.exists(bold1.fname) & file.exists(bold2.fname) & file.exists(bold3.fname) & file.exists(bold4.fname)) { 
    input.str.decon <- paste0("-input '", bold1.fname, "' '", bold2.fname, "' '", bold3.fname, "' '", bold4.fname, "'");
    input.str.reml  <- paste0('-input "', bold1.fname, " ", bold2.fname, " ", bold3.fname, " ", bold4.fname, '"');
  } else {
    input.str.decon <- "";
    input.str.reml <- "";
    print("didn't find a bold.nii.gz"); 
    was.success <- FALSE;
  }
  rm(bold1.fname, bold2.fname, bold3.fname, bold4.fname);  # cleanup
  
  # and check for previous output - afni won't overwrite, so stop if find files
  # I've made a more efficient way of doing this bit, but you can also just omit and watch for afni errors;
  # I put this in mostly for the RAs, to try to have somewhat sensible error messages.
  
  fname1 <- paste0(in.path, "AFNI_ANALYSIS/", sub.id, "/RESULTS_TENT20/FINE/STATS_", sub.id, "_REML.nii.gz");
  if (do.fine == TRUE & file.exists(fname1)) {
    print(paste0("ERROR: /RESULTS_TENT20/FINE/STATS_", sub.id, "_REML.nii.gz already exists."));
    was.success <- FALSE;
  }
  
  fname2 <- paste0(in.path, "AFNI_ANALYSIS/", sub.id, "/RESULTS_TENT20/COARSE/STATS_", sub.id, "_REML.nii.gz");
  if (do.coarse == TRUE & file.exists(fname2)) {
    print(paste0("ERROR: /RESULTS_TENT20/COARSE/STATS_", sub.id, "_REML.nii.gz already exists."));
    was.success <- FALSE;
  }
  
  fname3 <- paste0(in.path, "AFNI_ANALYSIS/", sub.id, "/RESULTS_TENT20/BOTH/STATS_", sub.id, "_REML.nii.gz");
  if (do.both == TRUE & file.exists(fname3)) {
    print(paste0("ERROR: /RESULTS_TENT20/BOTH/STATS_", sub.id, "_REML.nii.gz already exists."));
    was.success <- FALSE;
  }
  
  
  if (was.success == TRUE) {    # so far, so good, so keep going
    out.path <- paste0(in.path, "AFNI_ANALYSIS/", sub.id, "/RESULTS_TENT20/");
    if (!dir.exists(out.path)) { dir.create(out.path); }   # make the top-level output directory if needed
    
    # adapted from do.ON_MIXED  .... ON_TRIALS is actually closer to what you need; you don't have anything like BLOCKS or cue.
    if (do.both == TRUE) {
      print("starting BOTH GLM ...")
      
      # make the output directories
      out.path <- paste0(in.path, "AFNI_ANALYSIS/", sub.id, "/RESULTS_TENT20/BOTH/");  # actual output directory
      if (!dir.exists(out.path)) { dir.create(out.path); }
      setwd(out.path);  # needed for afni to write files in proper directory
      
      # call AFNI to do the GLM
      system_output <- system2(paste0(afni.path, "3dDeconvolve"),
                               args=paste0("-local_times -x1D_stop -GOFORIT 5 ", input.str.decon, " -polort A -float ",
                                           "-censor ", c.fname, " -num_stimts 2 ",
                                           "-stim_times 1 ", evt.path, sub.id, "_movie_fine.txt 'TENT(-10,20,16)' -stim_label 1 fine ",
                                           "-stim_times 2 ", evt.path, sub.id, "_movie_coarse.txt 'TENT(-10,20,16)' -stim_label 2 coarse ",
                                           "-ortvec ", mot.fname, " motion -x1D X.xmat.1D -xjpeg X.jpg -nobucket"), 
                               stdout=TRUE, stderr=TRUE);
      cat(system_output, sep = "\n")
      
      system_output <- system2(paste0(afni.path, "3dREMLfit"), 
                               args=paste0("-matrix X.xmat.1D -GOFORIT 5 ", input.str.reml, " ",
                                           "-Rvar stats_var_", sub.id, "_REML.nii.gz ",
                                           "-Rbuck STATS_", sub.id, "_REML.nii.gz ",
                                           "-fout -tout -nobout -verb"), stdout=TRUE, stderr=TRUE);
      cat(system_output, sep = "\n")
    }
    
    
    
    # # # # # # FINE GLM: volume # # # # # # 
    if (do.fine == TRUE) {
      print("starting FINE GLM ...")
      
      # make the output directories
      out.path <- paste0(in.path, "AFNI_ANALYSIS/", sub.id, "/RESULTS_TENT20/FINE/");  # actual output directory
      if (!dir.exists(out.path)) { dir.create(out.path); }
      setwd(out.path);  # needed for afni to write files in proper directory
      
      # call AFNI to do the GLM
      # note that afni output is stderr, not stdout!
      system_output <- system2(paste0(afni.path, "3dDeconvolve"),
                               args=paste0("-local_times -x1D_stop -GOFORIT 5 ", input.str.decon, " -polort A -float ",
                                           "-censor ", c.fname, " -num_stimts 1 ",
                                           "-stim_times 1 ", evt.path, sub.id, "_movie_fine.txt 'TENT(-10,20,16)' -stim_label 1 fine ",
                                           "-ortvec ", mot.fname, " motion -x1D X.xmat.1D -xjpeg X.jpg -nobucket"), 
                               stdout=TRUE, stderr=TRUE);
      cat(system_output, sep = "\n")
      
      system_output <- system2(paste0(afni.path, "3dREMLfit"), 
                               args=paste0("-matrix X.xmat.1D -GOFORIT 5 ", input.str.reml, " ",
                                           "-Rvar stats_var_", sub.id, "_REML.nii.gz ",
                                           "-Rbuck STATS_", sub.id, "_REML.nii.gz ",
                                           "-fout -tout -nobout -verb"), stdout=TRUE, stderr=TRUE);
      cat(system_output, sep = "\n")
    }
    
    
    
    # # # # # # COARSE GLM: volume # # # # # # 
    if (do.coarse == TRUE) {
      print("starting COARSE GLM ...")
      
      # make the output directories
      out.path <- paste0(in.path, "AFNI_ANALYSIS/", sub.id, "/RESULTS_TENT20/COARSE/");  # actual output directory
      if (!dir.exists(out.path)) { dir.create(out.path); }
      setwd(out.path);  # needed for afni to write files in proper directory
      
      # call AFNI to do the GLM
      system_output <- system2(paste0(afni.path, "3dDeconvolve"),
                               args=paste0("-local_times -x1D_stop -GOFORIT 5 ", input.str.decon, " -polort A -float ",
                                           "-censor ", c.fname, " -num_stimts 1 ",
                                           "-stim_times 1 ", evt.path, sub.id, "_movie_coarse.txt 'TENT(-10,20,16)' -stim_label 1 coarse ",
                                           "-ortvec ", mot.fname, " motion -x1D X.xmat.1D -xjpeg X.jpg -nobucket"), 
                               stdout=TRUE, stderr=TRUE);
      cat(system_output, sep = "\n")
      
      system_output <- system2(paste0(afni.path, "3dREMLfit"), 
                               args=paste0("-matrix X.xmat.1D -GOFORIT 5 ", input.str.reml, " ",
                                           "-Rvar stats_var_", sub.id, "_REML.nii.gz ",
                                           "-Rbuck STATS_", sub.id, "_REML.nii.gz ",
                                           "-fout -tout -nobout -verb"), stdout=TRUE, stderr=TRUE);
      cat(system_output, sep = "\n")
    }
    
    # STATS didn't all exist before, so check if expected ones are present now
    if (do.fine & !file.exists(fname1)) { was.success <- FALSE; }
    if (do.coarse & !file.exists(fname2)) { was.success <- FALSE; }
    if (do.both & !file.exists(fname3)) { was.success <- FALSE; }
  }
  
  if (was.success) { print(paste("do.GLMs.vol finished successfully!")); }
}



##################################################################################################################################################################
##################################################################################################################################################################
# make "parcel-average timecourses" of some of the STATS fields 
# input images are 81x96x81

do.parcelavg.vol <- function(sub.id) {     # sub.id <- "sub-03";
  was.success <- TRUE;   # initialize return value 
  
  # figure out which GLMs this person has from the EVTs
  # and the EVTs. evt files are present, but full of * when missing.
  evt.path <- paste0(in.path, "EVTs/", sub.id, "/"); # to shorten paths later
  fname <- paste0(evt.path, sub.id, "_movie_coarse.txt");
  if (file.exists(fname)) { 
    tmp <- readLines(fname); 
    if (length(tmp) == 4) {
      if (all.equal(tmp, rep("*", 4)) == TRUE) { do.coarse <- FALSE; } else { do.coarse <- TRUE; }
    } else { stop("invalid coarse EVT!"); }
  } else { stop("missing coarse EVT!"); }
  
  fname <- paste0(evt.path, sub.id, "_movie_fine.txt");
  if (file.exists(fname)) { 
    tmp <- readLines(fname); 
    if (length(tmp) == 4) {
      if (all.equal(tmp, rep("*", 4)) == TRUE) { do.fine <- FALSE; } else { do.fine <- TRUE; }
    } else { stop("invalid fine EVT!"); }
  } else { stop("missing fine EVT!"); }
  
  if (do.coarse == TRUE & do.fine == TRUE) { do.both <- TRUE; } else { do.both <- FALSE; }
  if (do.coarse == FALSE & do.fine == FALSE) { print("need coarse or fine EVTs"); was.success <- FALSE; }
  
  
  
  
  # # # # # # BOTH GLM # # # # # #
  # adapted from ON_TRIALS, and ON_MIXED for the loop over labels
  if (do.both == TRUE & was.success == TRUE) {
    print("... starting BOTH parcel averaging", quote=FALSE);
    glm.path <- paste0(in.path, "AFNI_ANALYSIS/", sub.id, "/RESULTS_TENT20/BOTH/"); # to shorten code below
    
    fname.STATS <- paste0(glm.path, "STATS_", sub.id, "_REML.nii.gz");   # input
    fname1 <- paste0(glm.path, sub.id, "_fine_Schaefer2018_400x7_vol.txt");  # one of the output files
    if (file.exists(fname.STATS) & !file.exists(fname1)) {   # proceed
      all.lbls <- system2(paste0(afni.path, "3dinfo"), args=paste0("-label ", fname.STATS), stdout=TRUE);
      all.lbls <- strsplit(all.lbls, "[|]")[[1]];   # need [|] since | is a special character
      if (length(all.lbls) != 67) { stop("ERROR: BOTH length(all.lbls) != 67"); }
      
      # we want the 15 _Coefs for each TENT-modeled regressor, plus the Full_Fstat (only non-TENT).
      for (do.par in c("TianSubcortexS2x3TMNI", "Schaefer2018_400x7")) {    # do.par <- "TianSubcortexS2x3TMNI";  # do.par <- "Schaefer2018_400x7"
        p.fname <- paste0(p.path, do.par, "_94x111x94.nii.gz");  # parcellation image
        
        # non-TENTs
        lbl <- "Full_Fstat";
        out.fname <- paste0(glm.path, sub.id, "_", lbl,"_", do.par, "_vol.txt");
        brick.num <- which(all.lbls %in% lbl)-1;      # index of the lbl (-1 since afni 0-based)
        if (!is.na(brick.num) & !file.exists(out.fname)) {
          system2(paste0(afni.path, "3dROIstats"),
                  args=paste0("-longnames -mask ", p.fname, " ", fname.STATS, "[", brick.num, "] > ", out.fname), stdout=TRUE);
        } else { print(paste("error, skipped", out.fname)); }
        
        # now 16 Coefs for each of the two regressors
        for (lbl in c("fine", "coarse")) {
          out.fname <- paste0(glm.path, sub.id, "_", lbl, "_", do.par, "_vol.txt");
          lbls <- paste0(lbl, "#", 0:15, "_Coef");   # full sub-brick names
          brick.nums <- paste0((which(all.lbls %in% lbls)-1), collapse=",");  # index of each lbls (-1 since afni 0-based)
          if (nchar(brick.nums) >= 11 & !file.exists(out.fname)) {
            system2(paste0(afni.path, "3dROIstats"),
                    # note that -longnames seems to not exist in afni_19
                    args=paste0("-longnames -mask ", p.fname, " '", fname.STATS, "[", brick.nums, "]' > ", out.fname), stdout=TRUE);
          } else { print(paste("error, skipped", out.fname)); }
        }
      }
    } else {   # not right mix of files to start
      if (!file.exists(fname.STATS)) {
        print(paste0("ERROR: /RESULTS_TENT20/BOTH/STATS_", sub.id, "_REML.nii.gz not found both EVTs found.")); 
        was.success <- FALSE; 
      }
      if (file.exists(fname1)) {
        print(paste0("ERROR: /RESULTS_TENT20/BOTH/", sub.id, "_fine_Schaefer2018_400x7_vol.txt found but both EVTs found.")); 
        was.success <- FALSE; 
      }
    }
  }
  
  
  
  # # # # # # COARSE GLM # # # # # #
  if (do.coarse== TRUE & was.success == TRUE) {
    print("... starting COARSE parcel averaging", quote=FALSE);
    glm.path <- paste0(in.path, "AFNI_ANALYSIS/", sub.id, "/RESULTS_TENT20/COARSE/"); # to shorten code below
    
    fname.STATS <- paste0(glm.path, "STATS_", sub.id, "_REML.nii.gz");   # input
    fname1 <- paste0(glm.path, sub.id, "_coarse_Schaefer2018_400x7_vol.txt");  # one of the output files
    if (file.exists(fname.STATS) & !file.exists(fname1)) {   # proceed
      all.lbls <- system2(paste0(afni.path, "3dinfo"), args=paste0("-label ", fname.STATS), stdout=TRUE);
      all.lbls <- strsplit(all.lbls, "[|]")[[1]];   # need [|] since | is a special character
      if (length(all.lbls) != 34) { stop("ERROR: COARSE length(all.lbls) != 34"); }
      
      # we want the 15 _Coefs for each TENT-modeled regressor, plus the Full_Fstat (only non-TENT).
      for (do.par in c("TianSubcortexS2x3TMNI", "Schaefer2018_400x7")) {    # do.par <- "TianSubcortexS2x3TMNI";  # do.par <- "Schaefer2018_400x7"
        p.fname <- paste0(p.path, do.par, "_94x111x94.nii.gz");  # parcellation image
        
        # non-TENTs
        lbl <- "Full_Fstat";
        out.fname <- paste0(glm.path, sub.id, "_", lbl,"_", do.par, "_vol.txt");
        brick.num <- which(all.lbls %in% lbl)-1;      # index of the lbl (-1 since afni 0-based)
        if (!is.na(brick.num) & !file.exists(out.fname)) {
          system2(paste0(afni.path, "3dROIstats"),
                  args=paste0("-longnames -mask ", p.fname, " ", fname.STATS, "[", brick.num, "] > ", out.fname), stdout=TRUE);
        } else { print(paste("error, skipped", out.fname)); }
        
        
        # now 16 Coefs for each of the TENT regressors
        lbl <- "coarse";
        out.fname <- paste0(glm.path, sub.id, "_", lbl, "_", do.par, "_vol.txt");
        lbls <- paste0(lbl, "#", 0:15, "_Coef");   # full sub-brick names
        brick.nums <- paste0((which(all.lbls %in% lbls)-1), collapse=",");  # index of each lbls (-1 since afni 0-based)
        if (nchar(brick.nums) >= 11 & !file.exists(out.fname)) {
          system2(paste0(afni.path, "3dROIstats"),
                  args=paste0("-longnames -mask ", p.fname, " '", fname.STATS, "[", brick.nums, "]' > ", out.fname), stdout=TRUE);
        } else { print(paste("error, skipped", out.fname)); }
      }
    } else {   # not right mix of files to start
      if (!file.exists(fname.STATS)) {
        print(paste0("ERROR: /RESULTS_TENT20/COARSE/STATS_", sub.id, "_REML.nii.gz not found but EVTs found.")); 
        was.success <- FALSE; 
      }
      if (file.exists(fname1)) {
        print(paste0("ERROR: /RESULTS_TENT20/COARSE/", sub.id, "_coarse_Schaefer2018_400x7_vol.txt found but EVTs found.")); 
        was.success <- FALSE; 
      }
    }
  }
  
  
  
  # # # # # # FINE GLM # # # # # #
  if (do.fine == TRUE & was.success == TRUE) {
    print("... starting FINE parcel averaging", quote=FALSE);
    glm.path <- paste0(in.path, "AFNI_ANALYSIS/", sub.id, "/RESULTS_TENT20/FINE/"); # to shorten code below
    
    fname.STATS <- paste0(glm.path, "STATS_", sub.id, "_REML.nii.gz");   # input
    fname1 <- paste0(glm.path, sub.id, "_fine_Schaefer2018_400x7_vol.txt");  # one of the output files
    if (file.exists(fname.STATS) & !file.exists(fname1)) {   # proceed
      all.lbls <- system2(paste0(afni.path, "3dinfo"), args=paste0("-label ", fname.STATS), stdout=TRUE);
      all.lbls <- strsplit(all.lbls, "[|]")[[1]];   # need [|] since | is a special character
      if (length(all.lbls) != 34) { stop("ERROR: FINE length(all.lbls) != 34"); }
      
      # we want the 11 _Coefs for each TENT-modeled regressor, plus the Full_Fstat (only non-TENT).
      for (do.par in c("TianSubcortexS2x3TMNI", "Schaefer2018_400x7")) {    # do.par <- "TianSubcortexS2x3TMNI";  # do.par <- "Schaefer2018_400x7"
        p.fname <- paste0(p.path, do.par, "_94x111x94.nii.gz");  # parcellation image
        
        # non-TENTs
        lbl <- "Full_Fstat";
        out.fname <- paste0(glm.path, sub.id, "_", lbl,"_", do.par, "_vol.txt");
        brick.num <- which(all.lbls %in% lbl)-1;      # index of the lbl (-1 since afni 0-based)
        if (!is.na(brick.num) & !file.exists(out.fname)) {
          system2(paste0(afni.path, "3dROIstats"),
                  args=paste0("-longnames -mask ", p.fname, " ", fname.STATS, "[", brick.num, "] > ", out.fname), stdout=TRUE);
        } else { print(paste("error, skipped", out.fname)); }
        
        
        # now 16 Coefs for each of the TENT regressors
        lbl <- "fine";
        out.fname <- paste0(glm.path, sub.id, "_", lbl, "_", do.par, "_vol.txt");
        lbls <- paste0(lbl, "#", 0:15, "_Coef");   # full sub-brick names
        brick.nums <- paste0((which(all.lbls %in% lbls)-1), collapse=",");  # index of each lbls (-1 since afni 0-based)
        if (nchar(brick.nums) >= 11 & !file.exists(out.fname)) {
          system2(paste0(afni.path, "3dROIstats"),
                  args=paste0("-longnames -mask ", p.fname, " '", fname.STATS, "[", brick.nums, "]' > ", out.fname), stdout=TRUE);
        } else { print(paste("error, skipped", out.fname)); }
      }
    } else {   # not right mix of files to start
      if (!file.exists(fname.STATS)) {
        print(paste0("ERROR: /RESULTS_TENT20/FINE/STATS_", sub.id, "_REML.nii.gz not found but EVTs found.")); 
        was.success <- FALSE; 
      }
      if (file.exists(fname1)) {
        print(paste0("ERROR: /RESULTS_TENT20/FINE/", sub.id, "_fine_Schaefer2018_400x7_vol.txt found but EVTs found.")); 
        was.success <- FALSE; 
      }
    }
  }
  
  
  if (was.success) { print(paste("do.parcelavg.vol finished successfully!")); }
}


##################################################################################################################################################################
# done
##################################################################################################################################################################









