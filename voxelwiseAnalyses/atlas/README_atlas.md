###############################################################################################################################################################
The nifti images were made by Jo Etzel Feb 2022 using this conversion code, then moved to /data/MARCER/ATLASES/
resample to have properly sized underlay & parcel images
81x96x81 for 2p4 (all acquisitions)
65x77x65 for 3p0

afni.path <- "/usr/local/pkg/afni_18/";   path to the afni function executables

template.fnames <- c("/data/nil-bluearc/ccp-hcp/DMCC_ALL_BACKUPS/ATLASES/Schaefer2018_Parcellations/MNI/Schaefer2018_1000Parcels_17Networks_order_FSLMNI152_1mm.nii.gz",
               "/data/nil-bluearc/ccp-hcp/DMCC_ALL_BACKUPS/ATLASES/Schaefer2018_Parcellations/MNI/Schaefer2018_400Parcels_7Networks_order_FSLMNI152_1mm.nii.gz",
               "/scratch2/HCP_S1200_GroupAvg_v1/S1200_AverageT1w_restore.nii.gz",
               "/data/nil-bluearc/ccp-hcp/DMCC_ALL_BACKUPS/ATLASES/HCP_subcortical/Atlas_ROIs.2.nii.gz");
3p0
ex.fname <- "/scratch2/JoEtzel/MARCER/acqPilots_preproc/sub-888/sub-888_ses-1_task-CuedtsPro_acq-3p0MB4FA66_run-1_sd.nii.gz";
out.fnames <- c("/scratch2/JoEtzel/MARCER/acqPilots_preproc/Schaefer2018_1000x17_MARCER3p0.nii.gz",
                "/scratch2/JoEtzel/MARCER/acqPilots_preproc/Schaefer2018_400x7_MARCER3p0.nii.gz",
                "/scratch2/JoEtzel/MARCER/acqPilots_preproc/HCP_S1200T1w_MARCER3p0.nii.gz",
                "/scratch2/JoEtzel/MARCER/acqPilots_preproc/subcortical_MARCER3p0.nii.gz")

for (i in 1:length(out.fnames)) {
  system2(paste0(afni.path, "3dresample"), args=paste0("-master ", ex.fname, " -prefix ", out.fnames[i], " -inset ", template.fnames[i]), stdout=TRUE);
}

###################################################################################################################################################################
subcorticalKey.csv has labels corresponding to the integer voxel values in subcortical_MARCER3p0.nii.gz.
These are from the HCP cifti subcortical space, made using wb_command -cifti-separate.
https://www.humanconnectome.org/software/workbench-command/-cifti-separate

###################################################################################################################################################################
13 December 2022
schaefer400x7NodeNames.txt is https://github.com/PennLINC/xcpEngine/blob/master/atlas/schaefer400x7/schaefer400x7NodeNames.txt
and gives the xcp parcel names for the 400x7 atlas: these are old, not the same as the names in
/data/nil-bluearc/ccp-hcp/DMCC_ALL_BACKUPS/ATLASES/Schaefer2018_Parcellations/HCP/fslr32k/cifti/Schaefer2018_400Parcels_7Networks_order_info.txt
see https://github.com/PennLINC/xcpEngine/issues/481

indexTable.csv is fetched from: https://github.com/PennLINC/xcpEngine/tree/master/atlas/TianSubcortexS2x3T and then modified to replace "-" with "_", avoiding R confusion (when reading the file, R will treat "-" as "."). This corresponds to TianSubcortexS2x3T parcellation.
TianSubcorx3TNodeNames.txt, TianSubcortexS2x3TMNI.nii.gz is fetched from the same repo.
Because our fMRI format follows "/data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/fmriprep/fmriprep/sub-18/func/sub-18_task-movie_run-2_space-MNI152NLin2009cAsym_boldref.nii.gz", we need to resample the TianSubcortexS2x3TMNI.nii.gz to match the fMRI space. This is done using the following code:
afni.path <- "/usr/local/pkg/afni_22/";   # path to the afni function executables on ccplinux1
example image with desired output dimensions
ex.fname <- "/data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/fmriprep/fmriprep/sub-18/func/sub-18_task-movie_run-2_space-MNI152NLin2009cAsym_boldref.nii.gz"
in.fname <- "/data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/voxelwiseAnalyses/TianSubcortexS2x3TMNI.nii.gz";
out.fname <- "/data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/voxelwiseAnalyses/TianSubcortexS2x3TMNI_94x111x94.nii.gz";  # filename of resampled subcortical
system2(paste0(afni.path, "3dresample"), args=paste0("-master ", ex.fname, " -prefix ", out.fname, " -inset ", in.fname), stdout=TRUE);

TODO: there is a difference 