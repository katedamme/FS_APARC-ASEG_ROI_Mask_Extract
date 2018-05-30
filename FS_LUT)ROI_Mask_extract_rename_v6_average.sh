# By Nadig and Damme, 2016
# Loop layer 1: Go through list of subjects
# Loop layer 2: go through each type of image, anat, anatorg, diff
# Loop layer 3: go through each region defined in the look up table, create a mask, apply it to the the asegtodiff file


#!# /bin/tcsh

foreach subj (`subject_list.txt`)
	echo ${subj}
	mri_convert -ot nii ${SUBJECTS_DIR}/${subj}/mri/aseg.mgz ${SUBJECTS_DIR}/${subj}/mri/aseg.nii.gz
		
		echo "pulling out freesurfer regions"
		foreach line ("`head -1308 /usr/local/freesurfer/FreeSurferColorLUT.txt | tail -1302`") 
			set argv = ($line)
			set roi = $1
			set roiname = $2
			if ( `echo $roi | grep -P '^\d+$'` != "") then
				echo 
				echo  "....................................................................."
				echo "extracting ${roiname} label which is ${roi} for ${subj}"
				echo  "....................................................................."
				echo

				mri_cor2label --c "${SUBJECTS_DIR}/${subj}/mri/aseg.nii.gz" --id ${roi} --l "${SUBJECTS_DIR}/${subj}/label/${subj}_${roi}_${roiname}.label"
### NOTE THAT THE ABOVE LINE WILL GENERATE A NUMBER OF FALSE ERRORS FOR "ISSUES" SUCH AS "Found 0 label voxels ERROR: found no voxels matching id ### lesion not found"
### CONVERTING LABEL TO VOLUME COULD BE DONE IN SAME LOOP HOWEVER IN SOME TERMINAL SET UPS YOU WILL HAVE THE PROCESS INITIATED PRIOR TO THE COMPLETION OF THE LABELS WRITING AND IN AN INSTANCE WHERE NO SUCH LABEL EXISTS (e.g. lesions) THIS WILL GENERATE UNNECESSARY ERRORS
			endif
		end
		foreach subjlabel (`ls ${SUBJECTS_DIR}/${subj}/label/${subj}_*.label`)
				echo 
				echo  "....................................................................."
				echo "converting label into nifti volume for ${subj}"
				echo  "....................................................................."
				echo
				mri_label2vol --label "${subjlabel}" --identity --temp "${SUBJECTS_DIR}/${subj}/mri/aseg.nii.gz" --o "${subjlabel}.nii.gz"
		end
end
