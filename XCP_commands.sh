SINGULARITY_CACHEDIR=/data/nil-external/dcl/
export SINGULARITY_CACHEDIR
singularity build /data/nil-external/dcl/Singularity_Image/xcpEngine.simg docker://pennbbl/xcpengine:latest

# WRAPPER COMMAND:
#xcpengine-singularity \
# --image /path/to/xcpengine.simg \
# -d /xcpEngine/designs/fc-36p.dsn \
# -c /path/to/cohort.csv \
# -r /path/to/data/directory \
# -i /path/to/workingdir \
# -o /path/to/outputdir

# OR
# SINGULARITY COMMAND:
'''
#anatomical data:
singularity run -B ${DATA_ROOT}:${HOME}/data \
 /data/applications/xcpEngine.simg \
 -d ${HOME}/data/anat-antsct.dsn \
 -c ${HOME}/data/anat_cohort.csv \
 -o ${HOME}/data/xcp_output \
 -t 1 \
 -r ${HOME}/data
'''

#functional data:

singularity run -B /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/:/data --cleanenv ../Singularity_Image/xcpEngine3.simg -d /data/XCPparam/fc-36p_despike.dsn -c /data/XCPparam/func_cohort.csv -o /data/XCP_OUTPUT -t 1 -i /data/WORKINGDIR2 -r /data


# subject 37 done main output folder
singularity run -B /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/:/data --cleanenv ../Singularity_Image/xcpEngine3.simg -d /data/XCPparam/fc-36p_despike.dsn -c /data/XCPparam/func_cohort_37.csv -o /data/XCP_OUTPUT_37 -t 1 -i /data/WORKINGDIR_37 -r /data

# subject 36 done
singularity run -B /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/:/data --cleanenv ../Singularity_Image/xcpEngine3.simg -d /data/XCPparam/fc-36p_despike.dsn -c /data/XCPparam/func_cohort_36.csv -o /data/XCP_OUTPUT_36 -t 1 -i /data/WORKINGDIR_36 -r /data

# subject 35 done
singularity run -B /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/:/data --cleanenv ../Singularity_Image/xcpEngine3.simg -d /data/XCPparam/fc-36p_despike.dsn -c /data/XCPparam/func_cohort_35.csv -o /data/XCP_OUTPUT_35 -t 1 -i /data/WORKINGDIR_35 -r /data

# subject 34 done
singularity run -B /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/:/data --cleanenv ../Singularity_Image/xcpEngine3.simg -d /data/XCPparam/fc-36p_despike.dsn -c /data/XCPparam/func_cohort_34.csv -o /data/XCP_OUTPUT_34 -t 1 -i /data/WORKINGDIR_34 -r /data

# subject 33 done
singularity run -B /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/:/data --cleanenv ../Singularity_Image/xcpEngine3.simg -d /data/XCPparam/fc-36p_despike.dsn -c /data/XCPparam/func_cohort_33.csv -o /data/XCP_OUTPUT_33 -t 1 -i /data/WORKINGDIR_33 -r /data

# subject 32 done
singularity run -B /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/:/data --cleanenv ../Singularity_Image/xcpEngine3.simg -d /data/XCPparam/fc-36p_despike.dsn -c /data/XCPparam/func_cohort_32.csv -o /data/XCP_OUTPUT_32 -t 1 -i /data/WORKINGDIR_32 -r /data

# subject 31 done
singularity run -B /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/:/data --cleanenv ../Singularity_Image/xcpEngine3.simg -d /data/XCPparam/fc-36p_despike.dsn -c /data/XCPparam/func_cohort_31.csv -o /data/XCP_OUTPUT_31 -t 1 -i /data/WORKINGDIR_31 -r /data

# subject 30 running
singularity run -B /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/:/data --cleanenv ../Singularity_Image/xcpEngine3.simg -d /data/XCPparam/fc-36p_despike.dsn -c /data/XCPparam/func_cohort_30.csv -o /data/XCP_OUTPUT_30 -t 1 -i /data/WORKINGDIR_30 -r /data

# subject 29
singularity run -B /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/:/data --cleanenv ../Singularity_Image/xcpEngine3.simg -d /data/XCPparam/fc-36p_despike.dsn -c /data/XCPparam/func_cohort_29.csv -o /data/XCP_OUTPUT_29 -t 1 -i /data/WORKINGDIR_29 -r /data

# subject 28
singularity run -B /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/:/data --cleanenv ../Singularity_Image/xcpEngine3.simg -d /data/XCPparam/fc-36p_despike.dsn -c /data/XCPparam/func_cohort_28.csv -o /data/XCP_OUTPUT_28 -t 1 -i /data/WORKINGDIR_28 -r /data

# subject 27
singularity run -B /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/:/data --cleanenv ../Singularity_Image/xcpEngine3.simg -d /data/XCPparam/fc-36p_despike.dsn -c /data/XCPparam/func_cohort_27.csv -o /data/XCP_OUTPUT_27 -t 1 -i /data/WORKINGDIR_27 -r /data

# subject 26
singularity run -B /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/:/data --cleanenv ../Singularity_Image/xcpEngine3.simg -d /data/XCPparam/fc-36p_despike.dsn -c /data/XCPparam/func_cohort_26.csv -o /data/XCP_OUTPUT_26 -t 1 -i /data/WORKINGDIR_26 -r /data

# subject 25
singularity run -B /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/:/data --cleanenv ../Singularity_Image/xcpEngine3.simg -d /data/XCPparam/fc-36p_despike.dsn -c /data/XCPparam/func_cohort_25.csv -o /data/XCP_OUTPUT_25 -t 1 -i /data/WORKINGDIR_25 -r /data

# subject 24
singularity run -B /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/:/data --cleanenv ../Singularity_Image/xcpEngine3.simg -d /data/XCPparam/fc-36p_despike.dsn -c /data/XCPparam/func_cohort_24.csv -o /data/XCP_OUTPUT_24 -t 1 -i /data/WORKINGDIR_24 -r /data

# subject 23
singularity run -B /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/:/data --cleanenv ../Singularity_Image/xcpEngine3.simg -d /data/XCPparam/fc-36p_despike.dsn -c /data/XCPparam/func_cohort_23.csv -o /data/XCP_OUTPUT_23 -t 1 -i /data/WORKINGDIR_23 -r /data

# subject 22
singularity run -B /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/:/data --cleanenv ../Singularity_Image/xcpEngine3.simg -d /data/XCPparam/fc-36p_despike.dsn -c /data/XCPparam/func_cohort_22.csv -o /data/XCP_OUTPUT_22 -t 1 -i /data/WORKINGDIR_22 -r /data

# subject 21
singularity run -B /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/:/data --cleanenv ../Singularity_Image/xcpEngine3.simg -d /data/XCPparam/fc-36p_despike.dsn -c /data/XCPparam/func_cohort_21.csv -o /data/XCP_OUTPUT_21 -t 1 -i /data/WORKINGDIR_21 -r /data

# subject 20 running
singularity run -B /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/:/data --cleanenv ../Singularity_Image/xcpEngine3.simg -d /data/XCPparam/fc-36p_despike.dsn -c /data/XCPparam/func_cohort_20.csv -o /data/XCP_OUTPUT_20 -t 1 -i /data/WORKINGDIR_20 -r /data

# subject 19
singularity run -B /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/:/data --cleanenv ../Singularity_Image/xcpEngine3.simg -d /data/XCPparam/fc-36p_despike.dsn -c /data/XCPparam/func_cohort_19.csv -o /data/XCP_OUTPUT_19 -t 1 -i /data/WORKINGDIR_19 -r /data

# subject 18
singularity run -B /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/:/data --cleanenv ../Singularity_Image/xcpEngine3.simg -d /data/XCPparam/fc-36p_despike.dsn -c /data/XCPparam/func_cohort_18.csv -o /data/XCP_OUTPUT_18 -t 1 -i /data/WORKINGDIR_18 -r /data

# subject 17
singularity run -B /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/:/data --cleanenv ../Singularity_Image/xcpEngine3.simg -d /data/XCPparam/fc-36p_despike.dsn -c /data/XCPparam/func_cohort_17.csv -o /data/XCP_OUTPUT_17 -t 1 -i /data/WORKINGDIR_17 -r /data

# subject 16
singularity run -B /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/:/data --cleanenv ../Singularity_Image/xcpEngine3.simg -d /data/XCPparam/fc-36p_despike.dsn -c /data/XCPparam/func_cohort_16.csv -o /data/XCP_OUTPUT_16 -t 1 -i /data/WORKINGDIR_16 -r /data

# subject 15
singularity run -B /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/:/data --cleanenv ../Singularity_Image/xcpEngine3.simg -d /data/XCPparam/fc-36p_despike.dsn -c /data/XCPparam/func_cohort_15.csv -o /data/XCP_OUTPUT_15 -t 1 -i /data/WORKINGDIR_15 -r /data

# subject 14
singularity run -B /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/:/data --cleanenv ../Singularity_Image/xcpEngine3.simg -d /data/XCPparam/fc-36p_despike.dsn -c /data/XCPparam/func_cohort_14.csv -o /data/XCP_OUTPUT_14 -t 1 -i /data/WORKINGDIR_14 -r /data

# subject 13
singularity run -B /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/:/data --cleanenv ../Singularity_Image/xcpEngine3.simg -d /data/XCPparam/fc-36p_despike.dsn -c /data/XCPparam/func_cohort_13.csv -o /data/XCP_OUTPUT_13 -t 1 -i /data/WORKINGDIR_13 -r /data

# subject 12
singularity run -B /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/:/data --cleanenv ../Singularity_Image/xcpEngine3.simg -d /data/XCPparam/fc-36p_despike.dsn -c /data/XCPparam/func_cohort_12.csv -o /data/XCP_OUTPUT_12 -t 1 -i /data/WORKINGDIR_12 -r /data

# subject 11
singularity run -B /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/:/data --cleanenv ../Singularity_Image/xcpEngine3.simg -d /data/XCPparam/fc-36p_despike.dsn -c /data/XCPparam/func_cohort_11.csv -o /data/XCP_OUTPUT_11 -t 1 -i /data/WORKINGDIR_11 -r /data

# subject 10
singularity run -B /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/:/data --cleanenv ../Singularity_Image/xcpEngine3.simg -d /data/XCPparam/fc-36p_despike.dsn -c /data/XCPparam/func_cohort_10.csv -o /data/XCP_OUTPUT_10 -t 1 -i /data/WORKINGDIR_10 -r /data

# subject 9
singularity run -B /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/:/data --cleanenv ../Singularity_Image/xcpEngine3.simg -d /data/XCPparam/fc-36p_despike.dsn -c /data/XCPparam/func_cohort_09.csv -o /data/XCP_OUTPUT_09 -t 1 -i /data/WORKINGDIR_09 -r /data

# subject 8
singularity run -B /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/:/data --cleanenv ../Singularity_Image/xcpEngine3.simg -d /data/XCPparam/fc-36p_despike.dsn -c /data/XCPparam/func_cohort_08.csv -o /data/XCP_OUTPUT_08 -t 1 -i /data/WORKINGDIR_08 -r /data

# subject 7
singularity run -B /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/:/data --cleanenv ../Singularity_Image/xcpEngine3.simg -d /data/XCPparam/fc-36p_despike.dsn -c /data/XCPparam/func_cohort_07.csv -o /data/XCP_OUTPUT_07 -t 1 -i /data/WORKINGDIR_07 -r /data

# subject 6
singularity run -B /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/:/data --cleanenv ../Singularity_Image/xcpEngine3.simg -d /data/XCPparam/fc-36p_despike.dsn -c /data/XCPparam/func_cohort_06.csv -o /data/XCP_OUTPUT_06 -t 1 -i /data/WORKINGDIR_06 -r /data

# subject 5
singularity run -B /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/:/data --cleanenv ../Singularity_Image/xcpEngine3.simg -d /data/XCPparam/fc-36p_despike.dsn -c /data/XCPparam/func_cohort_05.csv -o /data/XCP_OUTPUT_05 -t 1 -i /data/WORKINGDIR_05 -r /data

# subject 4
singularity run -B /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/:/data --cleanenv ../Singularity_Image/xcpEngine3.simg -d /data/XCPparam/fc-36p_despike.dsn -c /data/XCPparam/func_cohort_04.csv -o /data/XCP_OUTPUT_04 -t 1 -i /data/WORKINGDIR_04 -r /data

# subject 3
singularity run -B /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/:/data --cleanenv ../Singularity_Image/xcpEngine3.simg -d /data/XCPparam/fc-36p_despike.dsn -c /data/XCPparam/func_cohort_03.csv -o /data/XCP_OUTPUT_03 -t 1 -i /data/WORKINGDIR_03 -r /data

# subject 2
singularity run -B /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/:/data --cleanenv ../Singularity_Image/xcpEngine3.simg -d /data/XCPparam/fc-36p_despike.dsn -c /data/XCPparam/func_cohort_02.csv -o /data/XCP_OUTPUT_02 -t 1 -i /data/WORKINGDIR_02 -r /data

# subject 1
singularity run -B /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/:/data --cleanenv ../Singularity_Image/xcpEngine3.simg -d /data/XCPparam/fc-36p_despike.dsn -c /data/XCPparam/func_cohort_01.csv -o /data/XCP_OUTPUT_01 -t 1 -i /data/WORKINGDIR_01 -r /data

#Need to make cohort files

#xcpengine-singularity \
# --image /data/nil-external/dcl/Singularity_Image/xcpEngine.simg \
# -d 

# Tan tries with other configs: fc-24p_gsr.dsn and fc_24p.dsn
singularity run -B /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/:/data --cleanenv ../Singularity_Image/xcpEngine3.simg -d /data/XCPparam/fc-24p_gsr.dsn -c /data/XCPparam/func_cohort_02.csv -o /data/voxelwiseAnalyses/xcp_24p_gsr/XCP_OUTPUT_02 -t 1 -i /data/voxelwiseAnalyses/xcp_24p_gsr/WORKINGDIR_02 -r /data
singularity run -B /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/:/data --cleanenv ../Singularity_Image/xcpEngine3.simg -d /data/XCPparam/fc-24p.dsn -c /data/XCPparam/func_cohort_02.csv -o /data/voxelwiseAnalyses/xcp_24p/XCP_OUTPUT_02 -t 1 -i /data/voxelwiseAnalyses/xcp_24p/WORKINGDIR_02 -r /data
singularity run -B /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/:/data --cleanenv ../Singularity_Image/xcpEngine3.simg -d /data/XCPparam/fc-24p_gsr.dsn -c /data/XCPparam/func_cohort_33.csv -o /data/voxelwiseAnalyses/xcp_24p_gsr/XCP_OUTPUT_33 -t 1 -i /data/voxelwiseAnalyses/xcp_24p_gsr/WORKINGDIR_33 -r /data
singularity run -B /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/:/data --cleanenv ../Singularity_Image/xcpEngine3.simg -d /data/XCPparam/fc-24p.dsn -c /data/XCPparam/func_cohort_33.csv -o /data/voxelwiseAnalyses/xcp_24p/XCP_OUTPUT_33 -t 1 -i /data/voxelwiseAnalyses/xcp_24p/WORKINGDIR_33 -r /data

# Tan tries for the whole cohort: fc-24p_gsr.dsn and fc-36p_scrub.dsn
singularity run -B /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/:/data --cleanenv ../Singularity_Image/xcpEngine3.simg -d /data/XCPparam/fc-24p_gsr.dsn -c /data/XCPparam/func_cohort_all_47.csv -o /data/voxelwiseAnalyses/xcp_24p_gsr/XCP_OUTPUT_all_47 -t 1 -i /data/voxelwiseAnalyses/xcp_24p_gsr/WORKINGDIR_24p_gsr -r /data

singularity run -B /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/:/data --cleanenv ../Singularity_Image/xcpEngine3.simg -d /data/XCPparam/fc-36p_scrub.dsn -c /data/XCPparam/func_cohort_all_47.csv -o /data/voxelwiseAnalyses/xcp_36p_scrub/XCP_OUTPUT_all_47 -t 1 -i /data/voxelwiseAnalyses/xcp_36p_scrub/WORKINGDIR_36p_scrub -r /data

# Tan found errors with xcp_36p_scrub, rerun with subject 02 and 33 and compare
singularity run -B /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/:/data --cleanenv ../Singularity_Image/xcpEngine3.simg -d /data/XCPparam/fc-36p_scrub.dsn -c /data/XCPparam/func_cohort_02.csv -o /data/voxelwiseAnalyses/xcp_36p_scrub/XCP_OUTPUT_02 -t 1 -i /data/voxelwiseAnalyses/xcp_36p_scrub/WORKINGDIR_36p_scrub_02 -r /data

singularity run -B /data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/:/data --cleanenv ../Singularity_Image/xcpEngine3.simg -d /data/XCPparam/fc-36p_scrub.dsn -c /data/XCPparam/func_cohort_33.csv -o /data/voxelwiseAnalyses/xcp_36p_scrub/XCP_OUTPUT_33 -t 1 -i /data/voxelwiseAnalyses/xcp_36p_scrub/WORKINGDIR_36p_scrub_33 -r /data