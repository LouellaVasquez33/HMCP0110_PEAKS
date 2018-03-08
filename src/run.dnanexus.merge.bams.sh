#!/bin/bash

#sourcenexus
bash /home/louellavasquez/dx-toolkit/environment

#DNAnexus folders
inproject=HMCPREF
outproject=HMCPREF:/Strategy_HMCP_definition_Louella/BAMS_dedup.pooled

#remove Kate's outliers
Kate=/home/louellavasquez/HMCP0110_FEAT_DEFINITIONS/donors.Kates.sample.outliers.txt





conds=(PC IC)
groups=(HV CRC1-2 CRC3-4)

for group in ${groups[@]}
do
  
  for cond in ${conds[@]}
  do

    list="list.${group}.${cond}.5M.dedup.bams.from.DNAnexus.txt"
    echo $list

    inbams=$(cat $list | grep -v -f $Kate | awk '{print "-isorted_bams="$0}' | tr "\n" " ")
    echo $inbams | awk '{print "++ total samples",NF}'
    #echo $inbams
      
    dx select ${inproject} && dx run bamtools_merge --yes ${inbams} --destination=${outproject}

    
echo
done #cond
done #group

