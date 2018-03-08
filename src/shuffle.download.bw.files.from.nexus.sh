#bin/bash

odir="/home/louellavasquez/HMCP0110_FEAT_DEFINITIONS/DATA/BIGWIGS"
mkdir -p $odir

lists=(list.CRC1-2.PC.dedup.bams.from.DNAnexus.txt list.HV.PC.dedup.bams.from.DNAnexus.txt)
outlier="/home/louellavasquez/HMCP0110_FEAT_DEFINITIONS/Kates.sample.outliers.txt"


for list in "${lists[@]}"
do
  
  echo "++++list $list"
  cat $list | grep -v -f $outlier | shuf -n10 > tmp.download 
  
  for bam in $(cat tmp.download | head -n 5)
  do
      donor=$(echo $bam | cut -d"/" -f3 | cut -d- -f1 | sed 's/PC/IC/g')
      nlist=$(echo $list | sed 's/PC/IC/g' )
      
      bam=$(echo $bam | sed 's/bam/bw/g')
      #echo $bam
      input=$(grep $donor $nlist | sed 's/bam/bw/g')
      #echo $input
      
      #dx ls -la $bam
      #dx ls -la $input
      
      dx download -o $odir $bam
      dx download -o $odir $input
      echo
  done
  
done





