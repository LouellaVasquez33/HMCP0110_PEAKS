#!/bin/bash

#sourcenexus
bash /home/louellavasquez/dx-toolkit/environment



#DNAnexus folders
inproject=HMCPREF
outproject=HMCPREF:/Strategy_HMCP_definition_Louella



###########################################
# macs2 --> HV

pc=$(cat list.HV.PC.5M.dedup.bams.from.DNAnexus.txt | awk '{print "-itfile="$0}' |tr "\n" " " )
ic=$(cat list.HV.IC.5M.dedup.bams.from.DNAnexus.txt | awk '{print "-icfile="$0}' |tr "\n" " " )

dx select ${inproject} && dx run macs2_callpeak --yes ${pc} ${ic} -iextra_options="--reptag HMCP0110-HV-N48" --destination=${outproject} --instance-type=mem1_ssd2_x16
 

###########################################
# macs2 --> CRC1-2

pc=$(cat list.CRC1-2.PC.5M.dedup.bams.from.DNAnexus.txt | awk '{print "-itfile="$0}' |tr "\n" " " )
ic=$(cat list.CRC1-2.IC.5M.dedup.bams.from.DNAnexus.txt | awk '{print "-icfile="$0}' |tr "\n" " " )

dx select ${inproject} && dx run macs2_callpeak --yes ${pc} ${ic} -iextra_options="--reptag HMCP0110-CRC12-N38" --destination=${outproject} --instance-type=mem1_ssd2_x16
 


###########################################
# macs2 --> CRC2-3
pc=$(cat list.CRC3-4.PC.5M.dedup.bams.from.DNAnexus.txt | awk '{print "-itfile="$0}' |tr "\n" " " )
ic=$(cat list.CRC3-4.IC.5M.dedup.bams.from.DNAnexus.txt | awk '{print "-icfile="$0}' |tr "\n" " " )

dx select ${inproject} && dx run macs2_callpeak --yes ${pc} ${ic} -iextra_options="--reptag HMCP0110-CRC34-N19" --destination=${outproject} --instance-type=mem1_ssd2_x16
 


##### Albert's previous run for HMCP0110:
#dx select CEGX_Run461 && dx run  macs2_callpeak  --yes  -itfile="file-F8K23Pj0BVVB4pxg9zBGzF6q" -iextra_options=" " -icfile="file-F8K23fj05ZZVBFPv0GZJvqyf"
##### for HMCP0150:
#-iextra_options="--nomodel --extsize 166 " 