#!/bin/bash

datadir="/home/louellavasquez/HMCP0110_FEAT_DEFINITIONS/DATA/COUNTS_MACS2_peaks_pooled.bams"
groups=(HV CRC12 CRC34)
conds=(PC IC)


for group in "${groups[@]}"
do
  echo $group
for cond in "${conds[@]}"
do
  
  echo $cond

ofile="$datadir/frip.${group}.${cond}.HMCP0110.txt"
echo -n > $ofile
for bam in $(ls $datadir/*${cond}_*.HMCP0110-${group}*exon*)
do
  
  name=$(echo $bam | awk -F/ '{print $NF}')
  ntarget=$(zcat $bam | grep "Total mapped reads" | cut -f1 | cut -d: -f2 | xargs)
  ntotal=$(zcat $bam | grep "Total mapped reads" | cut -f2 | cut -d: -f2 | xargs)
  #frip=$((ntarget / ntotal))
  echo "$name $ntarget $ntotal" | awk '{print $0,$2/$3}' >> $ofile
  


done #bam
done #cond
echo
done #group