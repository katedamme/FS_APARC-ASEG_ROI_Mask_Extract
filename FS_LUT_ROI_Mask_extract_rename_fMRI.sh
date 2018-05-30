# SCRIPTING IN PROGRESS
# Damme & Nadig 2018 - for disssertation work
!# /bin/tcsh
foreach subj (`cat subject_list.txt`)
  reg-feat2anat --feat rs-fMRI.feat --subject bert
  aseg2feat --feat rs-fMRI.feat --aseg aparc+aseg
  ### NOTE TO KATE check to see that this is prooper default directorey and output structure
     # else mri_convert aparc+aseg.mgz aparc+aseg.nii.gz
  echo "pulling out freesurfer regions"
  ### below from A Nadig
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
   mri_cor2label --c "${SUBJECTS_DIR}/${subj}/rs-fmri.feat/reg/freesurfer/aparc+aseg.nii.gz" --id ${roi} --l "${SUBJECTS_DIR}/${subj}/rs-fMRI.feat/reg/freesurfer/${subj}_${roi}_${roiname}.label"
   ### NOTE THAT THE ABOVE LINE WILL GENERATE A NUMBER OF FALSE ERRORS FOR "ISSUES" SUCH AS "Found 0 label voxels ERROR: found no voxels matching id ### lesion not found"
### CONVERTING LABEL TO VOLUME COULD BE DONE IN JSAME LOOP HOWEVER IN SOME TERMINAL SET UPS YOU WILL HAVE THE PROCESS INITIATED PRIOR TO THE COMPLETION OF THE LABELS WRITING AND IN AN INSTANCE WHERE NO SUCH LABEL EXISTS (e.g. lesions) THIS WILL GENERATE UNNECESSARY ERRORS
			endif
		end
		foreach subjlabel (`ls ${SUBJECTS_DIR}/${subj}/rs-fMRI.feat/reg/freesurfer/${subj}_*.label`)
				echo 
				echo  "....................................................................."
				echo "converting label into nifti volume for ${subj}"
				echo  "....................................................................."
				echo
				mri_label2vol --label "${subjlabel}" --identity --temp "${SUBJECTS_DIR}/${subj}/rs-fMRI.feat/reg/freesurfer/aparc+aseg.nii.gz" --o "${subjlabel}.nii.gz"
		end
end
