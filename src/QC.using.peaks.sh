#!/bin/bash



hdir="/home/louellavasquez/HMCP0110_FEAT_DEFINITIONS/DATA/COUNTS_MACS2_peaks_pooled.bams"
datadir="/home/louellavasquez/HMCP0110_FEAT_DEFINITIONS/DATA/COUNTS_MACS2_peaks_pooled.bams/test_mapq_1_matched"

for file in $(ls $datadir/*PC*exon*gz)
do
  
  #echo $file
  name=$(echo $file | awk -F/ '{print $NF}' | cut -d. -f1-12)
  donor=$(echo $name | cut -d_ -f1 | sed 's/PC//g')
  q0=$(ls $hdir/${name}*exon*)
  
  IC0=$(ls $hdir/${donor}*IC*exon*.gz)
  IC1=$(ls $datadir/${donor}*IC*exon*.gz)
  
  
  #echo $q0
  
  zcat $file | wc -l
  zcat $q0 | wc -l
  
  tot0=$(zcat $q0 | grep "mapped reads" | cut -d: -f3 | xargs)
  tot1=$(zcat $file | grep "mapped reads" | cut -d: -f3 | xargs)
  echo "$donor $tot0 $tot1" | awk '{print "PC",$0,$3/$2}'
  
  tot0=$(zcat $IC0 | grep "mapped reads" | cut -d: -f3 | xargs)
  tot1=$(zcat $IC1 | grep "mapped reads" | cut -d: -f3 | xargs)
  echo "$donor $tot0 $tot1" | awk '{print "IC",$0,$3/$2}'
  
  echo
  
  Rscript plot.correlation.MAPQ.0vs1.R $q0 $file $IC0 $IC1 $donor
done