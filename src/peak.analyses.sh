#!/bin/bash

hdir="/home/louellavasquez/HMCP0110_FEAT_DEFINITIONS"

key=$1
key=hv.hmcp110

list=$2
list="list.CRC3-4.sorted.peak.file.loc.txt"

list="${hdir}/${list}"
#echo "list $list"

#mkdir -p TMP.$key


#make sure peak is sorted!!  sort -k1,1 -nk2,2
: <<'END'
for peak in $(cat $list)
do
#scp $peak TMP.$key/.
wc -l $peak
done
END



#intersect

#first three columns define the interval
#fourth column reports the number of files present at that interval
#the fifth column reports a comma-separated list of files present at that interval
#6th through 8th columns report whether (1) or not (0) each file is presen

#multiIntersectBed -i TMP.$key/* | awk '$4>=3' > consensus.peaks.$key.bed  



#bedops merge



#remove TMP files,folders




################################################################################
#  peaks by pooling bams per group

# compare pooled peak vs peak
: <<'END'

list="list.HV.sorted.peak.file.loc.txt"
poolhv="/home/louellavasquez/HMCP0110_FEAT_DEFINITIONS/sorted.HMCP0110-HV-N48.trep48.crep48.macs2_peaks.narrowPeak.bed"

name=$(echo $poolhv | awk -F/ '{print $NF}')
echo -n > vs.per.donor.peak_$name 
tcount=$(wc -l $poolhv | cut -d" " -f1)
for peak in $(cat $list)
do


olaps=$(bedops -e 10 $poolhv $peak | wc -l | awk -v TOTAL=$tcount '{print $0, $1/TOTAL}')
echo "$olaps $peak" >>  vs.per.donor.peak_$name 

done


# compare pooled peak vs peak
list="list.CRC1-2.sorted.peak.file.loc.txt"
poolcrc12="/home/louellavasquez/HMCP0110_FEAT_DEFINITIONS/sorted.HMCP0110-CRC12-N38.trep38.crep38.macs2_peaks.narrowPeak.bed"

name=$(echo $poolcrc12 | awk -F/ '{print $NF}')
echo -n > vs.per.donor.peak_$name 
tcount=$(wc -l $poolcrc12 | cut -d" " -f1)
for peak in $(cat $list)
do


olaps=$(bedops -e 10 $poolcrc12 $peak | wc -l | awk -v TOTAL=$tcount '{print $0, $1/TOTAL}')
echo "$olaps $peak" >>  vs.per.donor.peak_$name 

done

# compare pooled peak vs peak
list="list.CRC3-4.sorted.peak.file.loc.txt"
poolcrc34="/home/louellavasquez/HMCP0110_FEAT_DEFINITIONS/sorted.HMCP0110-CRC34-N19.trep19.crep19.macs2_peaks.narrowPeak.bed"

name=$(echo $poolcrc34 | awk -F/ '{print $NF}')
echo -n > vs.per.donor.peak_$name 
tcount=$(wc -l $poolcrc34 | cut -d" " -f1)
for peak in $(cat $list)
do


olaps=$(bedops -e 10 $poolcrc34 $peak | wc -l | awk -v TOTAL=$tcount '{print $0, $1/TOTAL}')
echo "$olaps $peak" >>  vs.per.donor.peak_$name 

done
END

###############


# look at intersection of peaks

hv="/home/louellavasquez/HMCP0110_FEAT_DEFINITIONS/DATA/MACS2_peaks_pooled.bams/HMCP0110-HV-N48.trep48.crep48.macs2_peaks.narrowPeak.gz"
crc12="/home/louellavasquez/HMCP0110_FEAT_DEFINITIONS/DATA/MACS2_peaks_pooled.bams/HMCP0110-CRC12-N38.trep38.crep38.macs2_peaks.narrowPeak.gz"
crc34="/home/louellavasquez/HMCP0110_FEAT_DEFINITIONS/DATA/MACS2_peaks_pooled.bams/HMCP0110-CRC34-N19.trep19.crep19.macs2_peaks.narrowPeak.gz"

hvname=$(echo $hv | awk -F/ '{print $NF}' | sed 's/.gz//g')
crc12name=$(echo $crc12 | awk -F/ '{print $NF}' | sed 's/.gz//g')
crc34name=$(echo $crc34 | awk -F/ '{print $NF}' | sed 's/.gz//g')
#echo $hvname

: <<'END'
zcat $hv | sort-bed - > sorted.$hvname.bed
zcat $crc12 | sort-bed - > sorted.$crc12name.bed
zcat $crc34 | sort-bed - > sorted.$crc34name.bed


bedops --merge sorted.$hvname.bed sorted.$crc12name.bed sorted.$crc34name.bed > merged.sorted.hv.crc12.crc34.pooled.bams.bed


bedops -e 10 merged.sorted.hv.crc12.crc34.pooled.bams.bed sorted.$hvname.bed > all.in.hv.bed
bedops -e 10 merged.sorted.hv.crc12.crc34.pooled.bams.bed sorted.$crc12name.bed > all.in.crc12.bed
bedops -e 10 merged.sorted.hv.crc12.crc34.pooled.bams.bed sorted.$crc34name.bed > all.in.crc34.bed


awk 'FNR==NR{a[$1,$2,$3]=$0;next}{print $0,a[$1,$2,$3]}' all.in.hv.bed merged.sorted.hv.crc12.crc34.pooled.bams.bed | awk '{ $4 = (NF == 6 ? 1 : 0) } 1' OFS="\t" - | cut -f1-4 > count.all.in.hv.bed
awk 'FNR==NR{a[$1,$2,$3]=$0;next}{print $0,a[$1,$2,$3]}' all.in.crc12.bed merged.sorted.hv.crc12.crc34.pooled.bams.bed | awk '{ $4 = (NF == 6 ? 1 : 0) } 1' OFS="\t" - | cut -f1-4 > count.all.in.crc12.bed
awk 'FNR==NR{a[$1,$2,$3]=$0;next}{print $0,a[$1,$2,$3]}' all.in.crc34.bed merged.sorted.hv.crc12.crc34.pooled.bams.bed | awk '{ $4 = (NF == 6 ? 1 : 0) } 1' OFS="\t" - | cut -f1-4 > count.all.in.crc34.bed
paste count.all.in.hv.bed count.all.in.crc12.bed count.all.in.crc34.bed |  cut -f1-4,8,12 > combined.counts.all.in.bed

END


##############################################################################
# make a peak count matrix
# matrix of :  COUNTS, RPM, RPKM  XX PC,IC


: <<'END'

 
echo "#####!!!! make peak count matrix"


#6 ReadCnt
#7 RPM
#8 RPKM

conds=(PC IC)
groups=(HV CRC12 CRC34)
datadir="/home/louellavasquez/HMCP0110_FEAT_DEFINITIONS/DATA/COUNTS_MACS2_peaks_pooled.bams"
odir=$datadir
colnames=(counts rpm rpkm)


arrayindex=8
#6 ReadCnt
#7 RPM
#8 RPKM
filename=${colnames[$((arrayindex-6))]}
echo "---> $filename"

echo
echo

cd $odir
for cond in "${conds[@]}"
do
for group in "${groups[@]}"
do
  
  echo "** $cond $group"
  
  i=0
  
  for file in  $(ls $datadir/CEG*-*-*${cond}_*.HMCP0110-${group}-N*.exon.tsv.gz)
  do
    
    i=$(( i + 1 ))
    #echo "$i" 
    echo $file | awk -F/ '{print $NF}'
    
    if [ $i -eq 1 ]
    then
      echo "---> start creating a file"
      echo "feat" > header.txt
      zcat $file | grep -v "#" | cut -f4 >  $filename.HMCP0110.$group.$cond.bed
    fi 
    donor=$(echo $file | awk -F/ '{print $NF}' | cut -d_ -f1)
    echo $donor >> header.txt
    
    ## paste numbers
    zcat $file | grep -v "#" | cut -f${arrayindex} | paste -d" " $filename.HMCP0110.$group.$cond.bed - > tmp.bed
    scp tmp.bed $filename.HMCP0110.$group.$cond.bed
    
    
  done # file
  header=$(cat header.txt | tr "\n" " ")
  echo $header
  sed  -i "1i ${header}" $filename.HMCP0110.$group.$cond.bed
  echo


done #group
done #cond


END





##############################################################################
#  filter peak count matrix to autosomes only chr1-22

#echo "#####!!!! filter peak count matrix"

#datadir="/home/louellavasquez/HMCP0110_FEAT_DEFINITIONS/DATA/COUNTS_MACS2_peaks_pooled.bams"
#datadir="/home/louellavasquez/HMCP0110_FEAT_DEFINITIONS/DATA/COUNTS_MACS2_merged.peaks_pooled.bams"
datadir="/home/louellavasquez/HMCP0110_FEAT_DEFINITIONS/DATA/COUNTS.pooled.bams_grp-specific.peaks"
odir=$datadir

: <<'END'
for peak in $(ls $datadir/*.bed | grep -v tmp)
do
   echo $peak
   name=$(echo $peak | awk -F/ '{print $NF}')
   
   cat $peak | awk '$1!~/chrX/' | awk '$1!~/chrY/' > ${odir}/chr1-22.only_${name}
  
done





for peak in $(ls $datadir/*.bed | grep -v tmp | grep -v only)
do
   echo $peak
   name=$(echo $peak | awk -F/ '{print $NF}')
   
   cat $peak | awk '$1~/chr20./'  > ${odir}/chr20.only_${name}
  
done

END


##############################################################################
# make a peak count matrix --- merged peaks X 3
# matrix of :  COUNTS, RPM, RPKM  XX PC,IC


: <<'END'

 
echo "#####!!!! make peak count matrix on merged 3x peak sets"


#6 ReadCnt
#7 RPM
#8 RPKM

conds=(PC IC)
groups=(HV CRC1-2 CRC3-4)
colnames=(counts rpm rpkm)

hdir="/home/louellavasquez/HMCP0110_FEAT_DEFINITIONS"
datadir="/home/louellavasquez/HMCP0110_FEAT_DEFINITIONS/DATA/COUNTS_MACS2_merged.peaks_pooled.bams"
odir=$datadir


arrayindex=8
#6 ReadCnt
#7 RPM
#8 RPKM
filename=${colnames[$((arrayindex-6))]}
echo "---> $filename"

echo
echo

cd $odir
for cond in "${conds[@]}"
do
for group in "${groups[@]}"
do
  
  echo "** $cond $group"
  
  i=0
  
  for file in  $(cat $hdir/list.${group}.peak.file.loc.txt  | awk -F/ '{print $NF}' | cut -d_ -f1)
  do
  
  if [ $cond == "IC" ]
  then
  file=$(echo $file | sed 's/PC/IC/g')
  fi
  
  
  file="$datadir/${file}_*.exon.tsv.gz"
    
    i=$(( i + 1 ))
    #echo "$i" 
    echo $file | awk -F/ '{print $NF}'
    
#: <<'END'
    
    if [ $i -eq 1 ]
    then
      echo "---> start creating a file"
      echo "feat" > header.txt
      zcat $file | grep -v "#" | cut -f4 >  $filename.HMCP0110.merged.3peaks.$group.$cond.bed
    fi 
    donor=$(echo $file | awk -F/ '{print $NF}' | cut -d_ -f1 | awk -v GRP="$group" '{print GRP"."$0}')
    echo $donor >> header.txt
    
    ## paste numbers
    zcat $file | grep -v "#" | cut -f${arrayindex} | paste -d" " $filename.HMCP0110.merged.3peaks.$group.$cond.bed - > tmp.bed
    scp tmp.bed $filename.HMCP0110.merged.3peaks.$group.$cond.bed

#END
  
  done # file
  echo "donor count is $i"  

  header=$(cat header.txt | tr "\n" " ")
  #echo $header
  sed  -i "1i ${header}" $filename.HMCP0110.merged.3peaks.$group.$cond.bed
  echo


done #group
done #cond


END


##############################################################################
###
### get seq depth of PC vc IC

: <<'END'
echo "### get seq depth PC vs IC"

hdir="/home/louellavasquez/HMCP0110_FEAT_DEFINITIONS/DATA/COUNTS_MACS2_merged.peaks_pooled.bams"
groups=(HV CRC1-2 CRC3-4)


for group in "${groups[@]}"
do
  echo "++++++ $group"
  echo -n > $group.seqdepth.PCvsIC.txt
  for file in $(cat list.${group}.PC.dedup.bams.from.DNAnexus.txt)
  do
    
    donor=$(echo $file | awk -F/ '{print $NF}' | cut -d_ -f1)
    dPC=$(zcat $hdir/${donor}_*.exon.tsv.gz |grep Total | cut -d: -f3- | xargs )
    donor=$(echo $donor | sed 's/PC/IC/g')
    dIC=$(zcat $hdir/${donor}_*.exon.tsv.gz |grep Total | cut -d: -f3- | xargs )
    
    echo "$dPC $dIC" >> $group.seqdepth.PCvsIC.txt
    
  done
  echo
  
done

END

##############################################################################
###
### get number of sig peaks per donor 

: <<'END'
echo "### get number of sig peaks per donor"

groups=(HV CRC1-2 CRC3-4)
countdir="/home/louellavasquez/HMCP0110_FEAT_DEFINITIONS/DATA/COUNTS_MACS2_merged.peaks_pooled.bams"

for group in "${groups[1]}"
do
list="list.${group}.sorted.peak.file.loc.txt"
echo "$group $list"

ofile=number.5FDR.per.donor.peaks.${group}.txt
echo "sample N.5FDR.peaks N.total.reads" > $ofile
for file in $(cat $list)
do

name=$(echo $file | awk -F/ '{print $NF}')  
donor=$(echo $file | awk -F/ '{print $NF}' | cut -d. -f2 | cut -d_ -f1)
countfile=$(ls $countdir/*${donor}*exon.tsv.gz)

npeak=$(wc -l $file | cut -d" " -f1)
ntotal=$(zcat $countfile | grep "Total mapped reads" | cut -f2 | cut -d: -f2 | xargs)
echo "$name $npeak $ntotal" >> $ofile
echo $donor
done # file
echo
done # group
END


##############################################################################
###
### get overlap of per sample peak vs reference peak sets
### merge sample peak + reference peak set = new tmp peak_
### calculate Jaccard index to asses degree of overlap

: <<'END'
echo "### get overlap of per sample peak vs reference peak sets "


groups=(HV CRC12 CRC34)

HVpeaklist="list.HV.sorted.peak.file.loc.txt"
CRC12peaklist="list.CRC1-2.sorted.peak.file.loc.txt"
CRC34peaklist="list.CRC3-4.sorted.peak.file.loc.txt"

for group in "${groups[@]}"
do


#peaklist=$(echo $"${group}peaklist")
#peaklist=$(echo ${!$group.peaklist})
peaklist=$(eval echo -e "\$${group}peaklist")
refpeak=$(ls sorted.HMCP0110-${group}-*.macs2_peaks.narrowPeak.bed)
#sorted.HMCP0110-CRC34-N19.trep19.crep19.macs2_peaks.narrowPeak.bed  
#sorted.HMCP0110-HV-N48.trep48.crep48.macs2_peaks.narrowPeak.bed



echo "newpeak list $peaklist"
echo "ref peak is $refpeak"
nref=$(wc -l $refpeak | cut -d" " -f1)

ofile="jaccard.per.donor.vs.grp-specific.refpeak.$group.txt"
echo "donor donor.Npeak ref.Npeak peak.Jaccard bp.Jaccard" > $ofile
for newpeak in $(cat $peaklist)
do
  
  
  namenewpeak=$(echo $newpeak | awk -F/ '{print $NF}')
  nnew=$(wc -l $newpeak | cut -d" " -f1)
  echo "newpeak $namenewpeak"
  
  #new ref = merged ref peak and new peak
  bedops --merge $refpeak $newpeak > tmp.merged.peak
  #count overlaps of new ref vs ref and vs new peak
  bedops -e 10 tmp.merged.peak $refpeak >  tmp.in.$refpeak
  bedops -e 10 tmp.merged.peak $newpeak >  tmp.in.$namenewpeak

  awk 'FNR==NR{a[$1,$2,$3]=$0;next}{print $0,a[$1,$2,$3]}' tmp.in.$refpeak tmp.merged.peak | awk '{ $4 = (NF == 6 ? 1 : 0) } 1' OFS="\t" - | cut -f1-4 > count.all.in.$refpeak
  awk 'FNR==NR{a[$1,$2,$3]=$0;next}{print $0,a[$1,$2,$3]}' tmp.in.$namenewpeak tmp.merged.peak | awk '{ $4 = (NF == 6 ? 1 : 0) } 1' OFS="\t" - | cut -f1-4 > count.all.in.$namenewpeak

  intersect=$(paste count.all.in.$namenewpeak count.all.in.$refpeak |  cut -f1-4,8 | awk '$4==1 && $5==1' | wc -l)
  union=$(cat tmp.merged.peak | wc -l)
  bedJac=$(bedtools jaccard -a $refpeak -b $newpeak | cut -f3 | sed -n 2p)
  
  
  echo "$namenewpeak $nnew $nref" | awk -v NUM=$intersect -v DENOM=$union -v BED=$bedJac '{print $0,NUM/DENOM,BED}' >> $ofile
  
  
done #newpeak
echo
echo
done #group
END



##############################################################################
# make a peak count matrix ---  counts of pooled bams on each grp-specific peak
# matrix of :  COUNTS, RPM, RPKM  XX PC,IC


: <<'END'

 
echo "#####!!!! make peak count matrix on pooled bams per  grp-specific peak set"


#6 ReadCnt
#7 RPM
#8 RPKM

conds=(PC IC)
groups=(HV CRC1-2 CRC3-4)
colnames=(counts rpm rpkm)

hdir="/home/louellavasquez/HMCP0110_FEAT_DEFINITIONS"
datadir="/home/louellavasquez/HMCP0110_FEAT_DEFINITIONS/DATA/COUNTS.pooled.bams_grp-specific.peaks"
odir=$datadir


arrayindex=8
#6 ReadCnt
#7 RPM
#8 RPKM
filename=${colnames[$((arrayindex-6))]}
echo "---> $filename"

echo
echo

cd $odir
for cond in "${conds[@]}"
do
for group in "${groups[@]}"
do
  
  echo "** $cond $group"
  
  i=0
  
    file=$(ls $datadir/pooled.${group}.${cond}.*.exon.tsv.gz)
      
    i=$(( i + 1 ))
    #echo "$i" 
    echo $file | awk -F/ '{print $NF}'
    
#: <<'END'
    
    if [ $i -eq 1 ]
    then
      echo "---> start creating a file"
      echo "feat" > header.txt
      zcat $file | grep -v "#" | cut -f4 >  $filename.HMCP0110.pooledbams.grp-specific-peaks.$group.$cond.bed
    fi 
    donor="pooled.$group"
    echo $donor >> header.txt
    
    ## paste numbers
    zcat $file | grep -v "#" | cut -f${arrayindex} | paste -d" " $filename.HMCP0110.pooledbams.grp-specific-peaks.$group.$cond.bed  - > tmp.bed
    scp tmp.bed $filename.HMCP0110.pooledbams.grp-specific-peaks.$group.$cond.bed
#END
  
  echo "donor count is $i"  

  header=$(cat header.txt | tr "\n" " ")
  #echo $header
  sed  -i "1i ${header}" $filename.HMCP0110.pooledbams.grp-specific-peaks.$group.$cond.bed
  echo


done #group
done #cond


END




##############################################################################
## for each peak in REF peakset, does the peak overlap by ** bp with query peak_

refpeak=sorted.HMCP0110-CRC12-N38.trep38.crep38.macs2_peaks.narrowPeak.bed
list="list.CRC1-2.sorted.peak.file.loc.txt"
ofile="binary.vs.per.donor.peak_${refpeak}"

#: <<'END'
cut -f1-3 $refpeak > $ofile
for query in $(cat /home/louellavasquez/HMCP0110_FEAT_DEFINITIONS/${list})
do

echo $query
#count how many peaks overlap per peak
bedmap --bp-ovr 10 --echo --count --delim "\t" $refpeak $query | cut -f11 | awk '{ $1 = ($1 > 0 ? 1 : $1) } 1'  > tmp.binary
paste -d"\t" $ofile tmp.binary > tmp.ofile
cp tmp.ofile $ofile

done
#END

cat $ofile | cut -f4- |  awk -F"\t" '{sum=0; for (i=1; i<=NF; i++) { sum+= $i } print sum}' > tmp.binary
paste -d"\t" tmp.binary $ofile > count.$ofile

echo -n > bins.count.$ofile
for i in {1..38}
do
 awk -v NMIN=$i '$1>=NMIN' count.$ofile | wc -l | awk -v NMIN="$i" '{print NMIN,$0}' >> bins.count.$ofile
done


