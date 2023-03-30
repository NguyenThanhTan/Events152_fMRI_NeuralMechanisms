# started 17 August 2022
# based on https://osf.io/vqe92/ D:\maile\manuscripts\Etzel2021_ScientificData\classifications\buttons_volume\controlAnalysis_prep_volume.R 
# preparatory code events152 fMRI analyses. Only volumes.
###############################################################################################################################################################
###############################################################################################################################################################
# np2-ize the images for each run. use the shorter filenames for the output images. 

rm(list=ls());    # clear R's memory
options(warnPartialMatchDollar=TRUE);   # safety option

in.path <- "/data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/fmriprep/fmriprep/";  # top-level fmriprep preprocessed dataset
out.path <- "/data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/voxelwiseAnalyses/np2/";   # where the new detrended images will be written
afni.path <- "/usr/local/pkg/afni_22/";   # path to the afni function executables

sub.ids <- c(paste0("0", 1:9), 10:47);
run.ids <- 1:4;
which.polort <- 2;    # see http://mvpa.blogspot.com/2018/06/detrending-and-normalizing-timecourses.html for more info

# the volume images preprocessed by fmriprep
for (sid in 1:length(sub.ids)) { 
  for (rid in 1:length(run.ids)) {  # sid <- 1; rid <- 1; 
    in.fname <- paste0(in.path, "sub-", sub.ids[sid], "/func/sub-", sub.ids[sid], "_task-movie_run-", rid, "_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz");
    out.fname <- paste0(out.path, "sub-", sub.ids[sid], "_run-", rid, "_np", which.polort, ".nii.gz");  
    if (file.exists(in.fname) & !file.exists(out.fname)) {      # call afni for the np-izing
      system2(paste0(afni.path, "3dDetrend"), args=paste0("-prefix ", out.fname, " -normalize -polort ", which.polort, " ", in.fname), stdout=TRUE);
    }
  }
}

###############################################################################################################################################################
###############################################################################################################################################################
# resample the Schaefer parcellation & HCP 1200 average anatomy to match the e152 images. 
# e152 images are 94 x 111 x 94, with voxels approx 2.1 mm isotropic (2.077 x 2.077 x 2.8)
# https://mvpa.blogspot.com/2016/05/resampling-images-with-afni-3dresample.html

afni.path <- "/usr/local/pkg/afni_22/";   # path to the afni function executables on ccplinux1

# example image with desired output dimensions
ex.fname <- "/data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/fmriprep/fmriprep/sub-18/func/sub-18_task-movie_run-2_space-MNI152NLin2009cAsym_boldref.nii.gz"

# Shaefer parcellation
in.fname <- "/data/nil-bluearc/ccp-hcp/DMCC_ALL_BACKUPS/ATLASES/Schaefer2018_Parcellations/MNI/Schaefer2018_400Parcels_7Networks_order_FSLMNI152_1mm.nii.gz";
# original from https://github.com/ThomasYeoLab/CBIG/blob/master/stable_projects/brain_parcellation/Schaefer2018_LocalGlobal/
out.fname <- "/data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/voxelwiseAnalyses/Schaefer2018_400x7_94x111x94.nii.gz";  # filename of resampled Schaefer parcellation image
system2(paste0(afni.path, "3dresample"), args=paste0("-master ", ex.fname, " -prefix ", out.fname, " -inset ", in.fname), stdout=TRUE);

# resample the underlay anatomy to match these images. 
in.fname <- "/scratch2/HCP_S1200_GroupAvg_v1/S1200_AverageT1w_restore.nii.gz";    # from https://balsa.wustl.edu/file/show/7qX8N
out.fname <- "/data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/voxelwiseAnalyses/HCP_S1200T1w_94x111x94.nii.gz";  # filename of resampled image
system2(paste0(afni.path, "3dresample"), args=paste0("-master ", ex.fname, " -prefix ", out.fname, " -inset ", in.fname), stdout=TRUE);

# subcortical (from the HCP template anatomy, extracted with wb_command)
in.fname <- "/data/nil-bluearc/ccp-hcp/DMCC_ALL_BACKUPS/ATLASES/HCP_subcortical/Atlas_ROIs.2.nii.gz";
out.fname <- "/data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/voxelwiseAnalyses/subcortical_94x111x94.nii.gz";  # filename of resampled subcortical
system2(paste0(afni.path, "3dresample"), args=paste0("-master ", ex.fname, " -prefix ", out.fname, " -inset ", in.fname), stdout=TRUE);

# subcortical (https://github.com/yetianmed/subcortex/blob/master/Group-Parcellation/3T/Subcortex-Only/Tian_Subcortex_S2_3T_2009cAsym.nii.gz)
in.fname <- "/data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/voxelwiseAnalyses/TianSubcortexS2x3TMNI.nii.gz";
out.fname <- "/data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/voxelwiseAnalyses/TianSubcortexS2x3TMNI_94x111x94.nii.gz";  # filename of resampled subcortical
system2(paste0(afni.path, "3dresample"), args=paste0("-master ", ex.fname, " -prefix ", out.fname, " -inset ", in.fname), stdout=TRUE);

###############################################################################################################################################################
###############################################################################################################################################################
# make parcel-average timecourses

rm(list=ls());    # clear R's memory
options(warnPartialMatchDollar=TRUE);   # safety option

afni.path <- "/usr/local/pkg/afni_22/";   # path to the afni function executables
img.path <- "/data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/voxelwiseAnalyses/np2/";   
#p.fname <- "/data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/voxelwiseAnalyses/Schaefer2018_400x7_94x111x94.nii.gz";  # made above

p.fname <- "/data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/voxelwiseAnalyses/subcortical_94x111x94.nii.gz"; 

sub.ids <- c(paste0("0", 1:9), 10:47);
run.ids <- 1:4;
which.polort <- 2;   # as used in the previous code block

for (sid in 1:length(sub.ids)) {
  for (rid in 1:length(run.ids)) {     # sid <- 1; rid <- 1; 
    np.fname <- paste0(img.path, "sub-", sub.ids[sid], "_run-", rid, "_np", which.polort, ".nii.gz"); 
    #txt.fname <- paste0(img.path, "sub-", sub.ids[sid], "_run-", rid,  "_np", which.polort, "_Sch400x7.txt");
    txt.fname <- paste0(img.path, "sub-", sub.ids[sid], "_run-", rid,  "_np", which.polort, "_subcortical.txt");
    
    if (file.exists(np.fname) & !file.exists(txt.fname)) {
      system2(paste0(afni.path, "3dROIstats"), args=paste0("-mask ", p.fname, " ", np.fname, " > ", txt.fname), stdout=TRUE);
    }
  }
}


###############################################################################################################################################################
###############################################################################################################################################################
# this was somthing Jo did for initial testing: do not use for real analyses
# resample the movie frame timeseries to match the TR (1.4830 sec).

# library(signal);  # for decimate, resample
# 
# rm(list=ls());    # clear R's memory
# options(warnPartialMatchDollar=TRUE);   # safety option
# 
# in.path <- "/data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/voxelwiseAnalyses/";
# 
# in.tbl <- read.csv(paste0(in.path, "1.2.3_C1_trim.csv"));
# 
# # > str(in.tbl)
# # 'data.frame':	17582 obs. of  5 variables:
# # $ time.s.          : num  0.0667 0.1 0.1333 0.1667 0.2 ...
# # $ pixel_change_mean: num  0 0 0 0 0 0 0 0 0 0 ...
# # $ pixel_change_var : num  0 0 0 0 0 0 0 0 0 0 ...
# # $ luminance_mean   : num  0 0 0 0 0 0 0 0 0 0 ...
# # $ luminance_var    : num  0 0 0 0 0 0 0 0 0 0 ...
# 
# tmp <- diff(in.tbl$time.s.)
# # unique(tmp)
# # [1] 0.03333333 0.03333333 0.03333333 0.03333333 0.03333333 0.03333333 0.03333333 0.03333333 0.03333333 0.03333333 0.03333333 0.03333333 0.03333333 0.03333333
# # [15] 0.03333333
# # so, all basically 1 frame per 0.0333333 sec;  1/0.03333333 = 30 frames/sec
# 
# # decimate(x, 4) go down to 1/4 of the points
# 
# # 1.483/0.033333   [1] 44.49044
# 
# tmp <- resample(in.tbl$pixel_change_mean, 0.033333, 1.483);  # 395 long output
# 
# # movie shorter since surrounded by fixations?
# (405-395)*1.483  # [1] 14.83 sec extra
# 395*1.483   # [1] 585.785, which is fairly close to the 586.103 movie duration in the events.tsv
# 
# 9.59843820007518/1.483   # 6.472312  # movie starts 6.5 TRs into the run? .... more or less.
# # perhaps start correlating the full resampled movie timeseries with the BOLD around 9.6+8 sec into the run; could try a few different offsets.
# 
# # a run1 events.tsv:
# # onset	duration	trial_type
# # 9.59843820007518	586.103	movie
# # 0.0	5.932	fixation
# # 595.7665763003752	4.449	fixation
# 
# # nframes <- c(405, 467, 402, 444);  # number of frames in each run
# 
# 
# ## 
# in.path <- "/data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/voxelwiseAnalyses/";
# 
# m.ids <- c("1.2.3_C1_trim", "2.4.1_C1_trim", "3.1.3_C1_trim", "6.3.9_C1_trim");
# for (mid in 1:length(m.ids)) {    # mid <- 1;
#   in.tbl <- read.csv(paste0(in.path, m.ids[mid], ".csv"));
#   tmp <- resample(in.tbl$pixel_change_mean, 0.033333, 1.483);  # get number of rows in downsampled file
#   
#   out.tbl <- array(NA, c(length(tmp), ncol(in.tbl)));
#   colnames(out.tbl) <- colnames(in.tbl);
#   for (i in 1:ncol(in.tbl)) { out.tbl[,i] <- resample(in.tbl[,i], 0.033333, 1.483); }
#   write.table(out.tbl, paste0(in.path, m.ids[mid], "_downsampled.txt"));
# }
# 
# # summary(diff(out.tbl[,1]))
# # Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# # 1.363   1.452   1.487   1.487   1.523   1.614 
# 
# ###############################################################################################################################################################
# ###############################################################################################################################################################
# # which movie is which run???
# 
# m.ids <- c("1.2.3_C1_trim", "2.4.1_C1_trim", "3.1.3_C1_trim", "6.3.9_C1_trim");
# # downsampled row counts: 395        435           395             458
# # raw row counts:  17582        19373             17577           20382
# 
# # nframes <- c(405, 467, 404, 444);  # number of frames in each run, run.ids order 
# 
# #, so movie names in run order are:
# c("1.2.3_C1_trim", "6.3.9_C1_trim", "3.1.3_C1_trim", "2.4.1_C1_trim");

