#!/bin/bash


    # uses: (1) Extract, demean motion parameter and make censor(threshold=0.3) file (using fmriPrep's "*confound.tsv")
    #       (2) Make data ready for afni GLM ( blur, scale (optionally-reorinet to LPI )

# If needed, do --> source ~/.login  (at terminal to load afni)
#==========================================================================#
#========== setting variable-->>>do it manually for now===================
#--------------------------------------------------------------------------------VARABLE:


read -p "ENTER SUBJECT IDs, SCW### format; e.g: SCW997 (You can copy/paste a string of several subjects, separated by spaces.): " SUBJ;  
#result_folder_name="PreGLM"
#runs=3
subjects=${SUBJ}
#subjects="3905"

echo " Script running - Do not close terminal window"
TASKS=("StroopBas" "StroopPro" "StroopRea")
TASKRUNS=("2" "2" "2") #To be indexed with TASKS;should match order of tasks
TASKIndex=0

#===============================================================================================#
#=================================
#===============================================================================================#
for subject in ${subjects} ; do #main subject loop
    echo " subject no: $subject"
    subDir="/data/nil-bluearc/ccp-hcp/StroopCW/DATA/PREPROCESSED/"$subject"/derivatives/fmriprep/sub-"$subject"/ses-1/func"
    #Skip subject in subjects list if preprocessed data doesn't exist - that means that a valid subject wasn't entered
    if [ ! -d "${subDir}" ]; then
        echo "no preprocessed data directory found for this subject; skipping subject."
    else
        #resultsDir="/data/MARCER/NickB/preGLM/output/sub-"$subject""
        resultsDir="/data/nil-bluearc/ccp-hcp/StroopCW/DATA/AFNI_ANALYSIS/"$subject"/INPUT_DATA"

        # create result dir if it doesn't exists:
        if [[  ! -d "${resultsDir}" ]]; then
		mkdir -p "${resultsDir}"
		#open permissions for the new directories created
		chmod ug+rwx "/data/nil-bluearc/ccp-hcp/StroopCW/DATA/AFNI_ANALYSIS/$subject/"
		chmod ug+rwx  ${resultsDir}
        else
		echo output dir "${resultsDir}" already exists.
        fi

        cd ${resultsDir}

        { #redirection braces for redirecting logs for each subject

        

        TASKIndex=-1 #must reset task index prior to looping through each task, so that TASKRUNS can pair with TASKS correctly. Increment by 1 at the top of loop.
        for task in ${TASKS[@]} ; do #task loop (for current subject) - loop through each space-delimited task in TASKS string
            TASKIndex=$((TASKIndex + 1)) #Set to -1 prior to task loop, and add 1 prior to rest of code in loop, so index starts at "0"


            #================================
            # step1:selecting and concatenating FD (framewise_displacement) from all runs to make single file;
            #================================  
            
            #Skip this section if FD_mask file already exists 
            if [[ -f "${subject}_${task}_FD_mask.txt" ]]; then
                echo " FD mask file for ${subject} ${task} already exists; skipping step..."
            else
                echo "concatenating FD from all runs for ${subject} ${task}"
                #remove any existing FD/FDMask files (from previous/failed attempts)
                #find ${resultsDir} -maxdepth 1 -type f -name ${subject}'_*_motion*.txt' -delete
                find ${resultsDir} -maxdepth 1 -type f -name ${subject}_${task}_'FD0*.txt' -delete 
                find ${resultsDir} -maxdepth 1 -type f -name ${subject}_${task}_FD.txt -delete
                find ${resultsDir} -maxdepth 1 -type f -name ${subject}_${task}_FD_mask.txt -delete

                for ((run=1; run<=TASKRUNS[TASKIndex]; run++)); do
                    file="${subDir}/sub-"${subject}"_ses-1_task-${task}_run-"${run}"_desc-confounds_timeseries.tsv"
                    if [[ -f "$file" ]];  then
                        echo $file
                    else
                        echo "WARNING : Could not find confounds.tsv file for ${subject} ${task} run ${run}"
                    exit
                    fi
                    
                    # collecting rows:
                    awk '
                    NR==1{
                        for (i=1;i<=NF;i++){
                        f[$i]=i
                        }
                        }
                    {print $(f["framewise_displacement"])}' $file > ${subject}_${task}_FD0${run}.txt
                   
                    # removing header from motion files and cating to a single file
                    sleep 0.1
                    tail -n+2 ${subject}_${task}_FD0${run}.txt >> ${subject}_${task}_FD.txt

                done # !!!!!!!!!!! I think there was an error that previously ran the next afni call (a couple lines down) for each run in the loop, which would overwrite the FD Mask file for every task run loop
                #clear out intermediary/temp files
                find ${resultsDir} -maxdepth 1 -type f -name ${subject}_${task}_'FD0*.txt' -delete 


                # CHANGE the n/a rows to 0:   sed -i '1s/^/0\n/' _6regressors.txt
                sed -i 's/n\/a/0/g' ${subject}_${task}_FD.txt #globally replace pattern "n/a" with "0" in the text file 

                1deval -expr 'within(a,0,0.9)' -a "${subject}_${task}_FD.txt" > "${subject}_${task}_FD_mask.txt"  # call afni to make the censoring file
            fi

            sleep 0.1

            #================================
            # step2:selecting 6 motion parameters and cating  motion  parameters from all runs to make single file;
            #================================
            #Skip this section if ${subject}_${task}_6regressors.txt file already exists 
            if [[ -f "${subject}_${task}_6regressors.txt" ]]; then
                echo " 6regressors file for ${subject} ${task} already exists; skipping step..."
            else
                echo "concatenating motion parameters from all runs for ${subject} ${task}"
                #remove any existing motion files (from previous/failed attempts)
                find ${resultsDir} -maxdepth 1 -type f -name ${subject}_${task}_motion0'*.txt' -delete
                find ${resultsDir} -maxdepth 1 -type f -name ${subject}_${task}_6regressors.txt -delete

                for ((run=1; run<=TASKRUNS[TASKIndex]; run++)); do
                    file="${subDir}/sub-"${subject}"_ses-1_task-${task}_run-"${run}"_desc-confounds_timeseries.tsv"
                    if [[ -f "$file" ]];  then
                        echo $file
                    else
                        echo "WARNING : Could not find confounds.tsv file for ${subject} ${task} run ${run}"
                    exit
                    fi
                    
                    # collecting rows:
                    awk '
                    NR==1{
                        for (i=1;i<=NF;i++){
                        f[$i]=i
                        }
                        }
                    {print $(f["trans_x"]),$(f["trans_y"]), $(f["trans_z"]), $(f["rot_x"]), $(f["rot_y"]), $(f["rot_z"])}' $file > ${subject}_${task}_motion0${run}.txt
                   
                    # removing header(eg X Y ...RotZ) from motion files and cating to a single file
                   sleep 0.1
                   tail -n+2 ${subject}_${task}_motion0${run}.txt >> ${subject}_${task}_6regressors.txt
                done # for run motion parameter
                #clear out intermediary/temp files
                find ${resultsDir} -maxdepth 1 -type f -name ${subject}_${task}_motion0'*.txt' -delete
            fi

            #echo  "================ timing  files look good================== "
            echo "=============Counting TR per run ======================="
            #rm ${subDir}/tr_count*.txt
            #remove any existing motion files (from previous/failed attempts)
            #find ${resultsDir} -maxdepth 1 -type f -name ${subject}'_*_motion*.txt' -delete
            find ${resultsDir} -maxdepth 1 -type f -name ${subject}_${task}'_tr_count0*.txt' -delete
            find ${resultsDir} -maxdepth 1 -type f -name ${subject}_${task}_total_tr.txt -delete
            for ((run=1; run<=TASKRUNS[TASKIndex]; run++)); do
                #if [[ -f "$subDir/sub-COGED"$subject"_ses-01_task-NbackCOGED_run-"$run"_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz" ]] ; then
                if [[ -f "${subDir}/sub-"${subject}"_ses-1_task-${task}_run-"${run}"_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz" ]];  then
                    echo $(3dinfo -nv "${subDir}/sub-"${subject}"_ses-1_task-${task}_run-"${run}"_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz") >${subject}_${task}_tr_count0${run}.txt
                else
                    echo "WARNING : could not find bold file for ${subj} run ${run}"
                    exit
                fi
            done
            sleep 0.1
            
            cat ${subject}_${task}_tr_count0*.txt | xargs >${subject}_${task}_total_tr.txt
            #"${subject}_${task}_total_tr"=\"`cat ${subject}_${task}_total_tr.txt`\"
            #"${subject}_${task}_total_tr"=\""`cat ${subject}_${task}_total_tr.txt`"\"
            total_tr=$(cat "${subject}_${task}"_total_tr.txt)
            echo " ${subject}_${task} total TR: $total_tr"
        
            #Clean up temp files
            find ${resultsDir} -maxdepth 1 -type f -name ${subject}_${task}'_tr_count0*.txt' -delete
            find ${resultsDir} -maxdepth 1 -type f -name ${subject}_${task}_total_tr.txt -delete


            #=================================================
            #compute de-meaned motion parameters (for use in regression)
            #Note-in previous script version, 6regressors_demean.txt was labeled _motion_demean.1D


            echo "computing: de-meaned motion parameters"
            #Skip this section if ${subject}_${task}_6regressors.txt file already exists 
            if [[ -f "${subject}_${task}_6regressors_demean.txt" ]]; then
                echo " 6regressors_demean file for ${subject} ${task} already exists; skipping step..."
            else
                1d_tool.py -infile "${subject}_${task}_6regressors.txt" \
                    -set_run_lengths $total_tr \
                    -demean \
                    -write "${resultsDir}/${subject}_${task}_6regressors_demean.txt" \
                    -overwrite
            fi
            if [[ -f "${subject}_${task}_censor_list.1D" || -f "${subject}_${task}_censor_data.1D" || -f "${subject}_${task}_censor_count.txt" ]]; then
                echo " censor_list.1D, censor_data.1D, and/or censor_count.txt for ${subject} ${task} already exists; skipping step..."
            else

                1d_tool.py -infile "${subject}_${task}_6regressors.txt" \
                    -set_run_lengths $total_tr \
                    -derivative -censor_prev_TR \
                    -collapse_cols euclidean_norm\
                    -moderate_mask -0.3 0.3    \
                    -write_censor  ${subject}_${task}_censor_list.1D \
                    -write_CENSORTR ${subject}_${task}_censor_data.1D \
                    -verb 0    \
                    -show_censor_count 1> ${subject}_${task}_censor_count.txt \
                    -overwrite
            fi

            #-----------------------------------------------------------------------------------------------       
            echo "===================================================================="
            echo "========= running VOLUMES: blur, scale and reorient to LPI ========="
            echo "===================================================================="

            for ((run=1; run<=TASKRUNS[TASKIndex]; run++)); do
                if [[ -f "${subDir}/sub-"${subject}"_ses-1_task-${task}_run-"${run}"_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz" ]] ; then
                    file=sub-"${subject}"_ses-1_task-${task}_run-"${run}"_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz
                else
                    echo "WARNING : could not find bold file for ${subject} ${task} run ${run}"
                    exit
                fi
                
                #If lpi_scale_blur6_$file already exists, skip this section. (None of the other intermediary files are kept currently)
                if [[ -f "${resultsDir}/lpi_scale_blur6_$file" ]]; then
                    echo " lpi_scale_blur6 file for ${subject} ${task} already exists; skipping step..."
                else

                    echo "======Running: blur (spatial smoothing) =========================="

                    3dBlurToFWHM \
                         -input "${subDir}"/$file \
                         -prefix "${resultsDir}"/blur6_$file \
                         -FWHM 6

                    echo "======Running: scale (to make afni GLMs happy) =========================="

                    # https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dTstat.html  calculates the voxelwise mean
                    3dTstat \
                        -prefix ${resultsDir}/mean_blur6_$file ${resultsDir}/blur6_$file

                    3dcalc \
                        -a ${resultsDir}/blur6_$file \
                        -b ${resultsDir}/mean_blur6_$file \
                        -expr 'min(200, a/b*100)*step(a)*step(b)' \
                        -prefix ${resultsDir}/scale_blur6_$file
                    
                    echo "======Running:reorient :to LPI (set orientation/handedness of 3d array to make Jo happy) ============="

                    3dresample \
                        -orient LPI \
                        -prefix ${resultsDir}/lpi_scale_blur6_$file \
                        -inset ${resultsDir}/scale_blur6_$file


                    # to keep any of these, just delete its rm statement:
                    # only delete these if the final file has been made
                    if [ -f ${resultsDir}/lpi_scale_blur6_$file ]; then
                        rm ${resultsDir}/blur6_$file
                        rm ${resultsDir}/mean_blur6_$file
                        rm ${resultsDir}/scale_blur6_$file
                    fi
                fi


                echo "===================================================================="
                echo "========= running SURFACE: scale (to make afni GLMs happy) ========="
                echo "===================================================================="
                #### ADD here for scaling the surfaces. SHOULD (hopefully) be the same syntax and commands for the surfaces,
                #### but use the .gii images as input and output instead of the nii.gz ones.
                #### plus a L & R hemisphere for each run. e.g., sub-3085_ses-1_task-COGED_run-2_space-fsaverage5_hemi-R_bold.func.gii
                #### and sub-3085_ses-1_task-COGED_run-2_space-fsaverage5_hemi-L_bold.func.gii are the surface versions of
                #### sub-3085_ses-1_task-COGED_run-2_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz.

                #### LPI, blur doesn't apply to surfaces (not sensible for them); the same FD applies to surfaces and volumes
                #### so just need to do the FD, LPI, blur bits once. 

                #check for surface files
                
                files="sub-${subject}_ses-1_task-${task}_run-${run}_space-fsaverage5_hemi-L_bold.func.gii sub-${subject}_ses-1_task-${task}_run-${run}_space-fsaverage5_hemi-R_bold.func.gii"
                
                for file in ${files}; do
                    # Does file exist?
                    echo "${subDir}/${file}"
                    if [[ -e "${subDir}/${file}" ]]; then
                        #batch_job="demean_descale_Surface_${subject}_${file}"


                        #pushd ${resultsDir}
                        #echo "-prefix ${subDir}/mask_$file ${subDir}/$file" ??? not sure what this is supposed to do (mask vs below mean?)

                        #Skip this step if final output, scale_$file, already exists
                        if [[ -f "${resultsDir}/scale_$file" ]]; then
                            echo " scale file for ${subject} ${task} already exists; skipping step..."
                        else

                            3dTstat \
                                -prefix ${resultsDir}/mean_$file ${subDir}/$file

                            3dcalc \
                                -a ${subDir}/$file \
                                -b ${resultsDir}/mean_$file \
                                -expr 'min(200, a/b*100)*step(a)*step(b)' \
                                -prefix ${resultsDir}/scale_$file

                            # reorient to LPI

                            #3dresample \
                            #    -prefix ${resultsDir}/lpi_scale_$file \
                            #    -inset ${resultsDir}/scale_$file

                            #popd

                            # to keep any of these, just delete its rm statement:
                            #if [ -f ${resultsDir}/lpi_scale_$file ]; then
                            #    rm ${resultsDir}/mean_$file
                            #    rm ${resultsDir}/scale_$file
                            #    #rm ${file}
                            #fi

                            # to keep any of these, just delete its rm statement:
                            if [ -f ${resultsDir}/scale_$file ]; then
                                rm ${resultsDir}/mean_$file
                                #rm ${file}
                            fi
                        fi

                    else
                        echo "WARNING : file ${file} doesn't exist, skipping it. Check if this is correct."
                    fi # file exists

                done # for each file in files
                #    if [[ -f "${subDir}/sub-"${subject}"_ses-1_task-${task}_run-"${run}"_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz" ]] ; then
                #    file=sub-"${subject}"_ses-1_task-${task}_run-"${run}"_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz
               # else
                #    echo "WARNING : could not find bold file for ${subject} ${task} run ${run}"
                #    exit
                #fi


                # https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dTstat.html  calculates the voxelwise mean
                #3dTstat \
                #     -prefix ${resultsDir}/mean_blur6_$file ${resultsDir}/blur6_$file

                # 3dcalc \
                #     -a ${resultsDir}/blur6_$file \
                #     -b ${resultsDir}/mean_blur6_$file \
                #     -expr 'min(200, a/b*100)*step(a)*step(b)' \
                #     -prefix ${resultsDir}/scale_blur6_$file


                # # to keep any of these, just delete its rm statement:
                # # only delete these if the final file has been made

                # if [ -f ${resultsDir}/lpi_scale_blur6_$file ]; then
                #     rm ${resultsDir}/blur6_$file
                #     rm ${resultsDir}/mean_blur6_$file
                #     rm ${resultsDir}/scale_blur6_$file
                # fi

            done   # end run loop
        done # end Task Loop
        } >> ${resultsDir}/"sub-"$subject"_MARCER_PreGLMLog.txt" 2>&1
    fi
done  # end subject loop
# exit

echo " Script finished"
