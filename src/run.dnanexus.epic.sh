#!/bin/bash 

#sourcenexus
bash /home/louellavasquez/dx-toolkit/environment


#DNAnexus folders
inproject=HMCPREF
outproject=HMCPREF:/Strategy_HMCP_definition_Louella/EPIC_peaks_pooled.bams



#download per donor peaks
: <<'END'

hdir="/home/louellavasquez/HMCP0110_FEAT_DEFINITIONS"
odir="/home/louellavasquez/HMCP0110_FEAT_DEFINITIONS/DATA/HMCP0110_epic.peaks_per.donor"
cd $odir

for row in $(cat ${hdir}/list.*.PC.dedup.bams.from.DNAnexus.txt | awk -F/ '{$NF="";print $0}' OFS="/")
do
  echo $row
  dx download ${row}*epic*.tsv.gz
  
done
END



#run epic on pooled 5M donor bams

###########################################
#  epic --> HV

pc=$(cat list.HV.PC.5M.dedup.bams.from.DNAnexus.txt | awk '{print "-itfile="$0}' |tr "\n" " " )
ic=$(cat list.HV.IC.5M.dedup.bams.from.DNAnexus.txt | awk '{print "-icfile="$0}' |tr "\n" " " )

dx select ${inproject} && dx run epic_callpeak --yes ${pc} ${ic} -iextra_options="--outfile epic-HMCP0110-HV-N48" --destination=${outproject} --instance-type=mem3_ssd1_x32
 

###########################################
# epic --> CRC1-2

pc=$(cat list.CRC1-2.PC.5M.dedup.bams.from.DNAnexus.txt | awk '{print "-itfile="$0}' |tr "\n" " " )
ic=$(cat list.CRC1-2.IC.5M.dedup.bams.from.DNAnexus.txt | awk '{print "-icfile="$0}' |tr "\n" " " )

dx select ${inproject} && dx run epic_callpeak --yes ${pc} ${ic} -iextra_options="--outfile epic-HMCP0110-CRC12-N38" --destination=${outproject} --instance-type=mem3_ssd1_x32
 


###########################################
# epic --> CRC3-4
pc=$(cat list.CRC3-4.PC.5M.dedup.bams.from.DNAnexus.txt | awk '{print "-itfile="$0}' |tr "\n" " " )
ic=$(cat list.CRC3-4.IC.5M.dedup.bams.from.DNAnexus.txt | awk '{print "-icfile="$0}' |tr "\n" " " )

#dx select ${inproject} && dx run epic_callpeak --yes ${pc} ${ic} -iextra_options="--outfile epic-HMCP0110-CRC34-N19" --destination=${outproject} --instance-type=mem1_ssd2_x16
 
