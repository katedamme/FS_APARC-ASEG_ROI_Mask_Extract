# Intended to extract all Rois in diffusion space from a by product of TRACULA, makes all labels and volumes in dlabel/diff/
# Can be used as native space ROIs and as seeds for prbabilistic tractography (as described in Damme, Young, & Nusslock, 2017: https://academic.oup.com/scan/article/12/6/928/3002823 )
# By Damme & Nadig, 2017
# Loop layer 1: Go through list of subjects
# Loop layer 2: go through each region defined in the look up table, create a mask, apply it to the the asegtodiff file


#!# /bin/tcsh

foreach subj (`subject_list.txt`)
	echo ${subj}
		
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

				mri_cor2label --c "${SUBJECTS_DIR}/${subj}/dlabel/diff/aparc+aseg.bbr.nii.gz" --id ${roi} --l "${SUBJECTS_DIR}/${subj}/dlabel/diff/${subj}_${roi}_${roiname}.label"
### NOTE THAT THE ABOVE LINE WILL GENERATE A NUMBER OF FALSE ERRORS FOR "ISSUES" SUCH AS "Found 0 label voxels ERROR: found no voxels matching id ### lesion not found"
### CONVERTING LABEL TO VOLUME COULD BE DONE IN JSAME LOOP HOWEVER IN SOME TERMINAL SET UPS YOU WILL HAVE THE PROCESS INITIATED PRIOR TO THE COMPLETION OF THE LABELS WRITING AND IN AN INSTANCE WHERE NO SUCH LABEL EXISTS (e.g. lesions) THIS WILL GENERATE UNNECESSARY ERRORS
			endif
		end
		foreach subjlabel (`ls ${SUBJECTS_DIR}/${subj}/dlabel/diff/${subj}_*.label`)
				echo 
				echo  "....................................................................."
				echo "converting label into nifti volume for ${subj}"
				echo  "....................................................................."
				echo
				mri_label2vol --label "${subjlabel}" --identity --temp "${SUBJECTS_DIR}/${subj}/dlabel/diff/aparc+aseg.bbr.nii.gz" --o "${SUBJECTS_DIR}/${subj}/dlabel/diff/`echo ${subjlabel}|cut -d\/ -f9`.nii.gz"
		end
end



	
