#!/bin/bash

#sourcenexus
bash /home/louellavasquez/dx-toolkit/environment

##############################################################################
# get 4 columns of meta macs2_peaks
# rename peaks
# names must be unique


: <<'END'

for peak in $(ls sorted.*)
do
echo $peak

#cut -f1-3 $peak | awk '{print $1,$2,$3,$1"."$2"."$3}' OFS="\t" | bgzip > reformatted.$peak.gz
  
done

#dx select HMCPREF
#dx upload reformat*

END

##############################################################################
### HV samples


#DNAnexus folders
inproject=HMCPREF
outproject="HMCPREF:/Strategy_HMCP_definition_Louella/COUNTS_MACS2_peaks_pooled.bams"

: <<'END'


list=("list.HV.PC.dedup.bams.from.DNAnexus.txt" "list.HV.IC.dedup.bams.from.DNAnexus.txt")

echo
for bamlist in "${list[@]}"
do

echo "list $bamlist"

for bam in $(cat $bamlist)
do
echo "in bam $bam"

# -iextra_options='' --> RPM/RPKMS using total reads per bam
job=$(echo "dx run bam_readcount --yes \
-ireference_fastagz="Genomes:/Homo_sapiens/NCBI/GRCh38Decoy/Sequence/WholeGenomeFasta/Homo_sapiens_NCBI_GRCh38Decoy.genome.fa.gz" \
-ibedfile=HMCPREF:/Strategy_HMCP_definition_Louella/MACS2_peaks_pooled.bams/reformatted.sorted.HMCP0110-HV-N48.trep48.crep48.macs2_peaks.narrowPeak.bed.gz \
-ibamfile=${bam}  \
-ibaifile=${bam}.bai --destination=${outproject} \
-iextra_options=''")


dx select ${inproject} && $job

done #bam
echo
echo
done #bamlist

END


##############################################################################
### CRC1-2 samples

#DNAnexus folders
inproject=HMCPREF
#outproject="HMCPREF:/Strategy_HMCP_definition_Louella/COUNTS_MACS2_peaks_pooled.bams"
outproject="HMCPREF:/Strategy_HMCP_definition_Louella/COUNTS_MACS2_peaks_pooled.bams/test_mapq_1_matched"

#: <<'END'


list=("list.CRC1-2.PC.dedup.bams.from.DNAnexus.txt" "list.CRC1-2.IC.dedup.bams.from.DNAnexus.txt")
list=("sorted.filtered.list.CRC1-2.PC.dedup.bams.from.DNAnexus.txt" "sorted.filtered.list.CRC1-2.IC.dedup.bams.from.DNAnexus.txt")

echo
for bamlist in "${list[@]}"
do

echo "list $bamlist"

for bam in $(cat $bamlist | head -n5)
do
echo "in bam $bam"

# -iextra_options='' --> RPM/RPKMS using total reads per bam
job=$(echo "dx run bam_readcount --yes \
-ireference_fastagz="Genomes:/Homo_sapiens/NCBI/GRCh38Decoy/Sequence/WholeGenomeFasta/Homo_sapiens_NCBI_GRCh38Decoy.genome.fa.gz" \
-ibedfile=HMCPREF:/Strategy_HMCP_definition_Louella/MACS2_peaks_pooled.bams/reformatted.sorted.HMCP0110-CRC12-N38.trep38.crep38.macs2_peaks.narrowPeak.bed.gz \
-ibamfile=${bam}  \
-ibaifile=${bam}.bai --destination=${outproject} \
-iextra_options='--min_map_quality'")


dx select ${inproject} && $job

done #bam
echo
echo
done #bamlist

#END

##############################################################################
### CRC3-4 samples

#DNAnexus folders
inproject=HMCPREF
outproject="HMCPREF:/Strategy_HMCP_definition_Louella/COUNTS_MACS2_peaks_pooled.bams"

: <<'END'


list=("list.CRC3-4.PC.dedup.bams.from.DNAnexus.txt" "list.CRC3-4.IC.dedup.bams.from.DNAnexus.txt")

echo
for bamlist in "${list[@]}"
do

echo "list $bamlist"

for bam in $(cat $bamlist)
do
echo "in bam $bam"

# -iextra_options='' --> RPM/RPKMS using total reads per bam
job=$(echo "dx run bam_readcount --yes \
-ireference_fastagz="Genomes:/Homo_sapiens/NCBI/GRCh38Decoy/Sequence/WholeGenomeFasta/Homo_sapiens_NCBI_GRCh38Decoy.genome.fa.gz" \
-ibedfile=HMCPREF:/Strategy_HMCP_definition_Louella/MACS2_peaks_pooled.bams/reformatted.sorted.HMCP0110-CRC34-N19.trep19.crep19.macs2_peaks.narrowPeak.bed.gz \
-ibamfile=${bam}  \
-ibaifile=${bam}.bai --destination=${outproject} \
-iextra_options=''")


dx select ${inproject} && $job

done #bam
echo
echo
done #bamlist

END

##############################################################################
### all 105 samples + inputs == 210 samples
### using one reference peak set == merged 3X peakset

#DNAnexus folders
inproject=HMCPREF
outproject="HMCPREF:/Strategy_HMCP_definition_Louella/COUNTS_MACS2_merged.peaks_pooled.bams"

: <<'END'


conds=(PC IC)

echo
for cond in "${conds[@]}"
do

echo "cond $cond"

for bam in $(cat list.*.${cond}.dedup.bams.from.DNAnexus.txt)
do
echo "in bam $bam"


# -iextra_options='' --> RPM/RPKMS using total reads per bam
job=$(echo "dx run bam_readcount --yes \
-ireference_fastagz="Genomes:/Homo_sapiens/NCBI/GRCh38Decoy/Sequence/WholeGenomeFasta/Homo_sapiens_NCBI_GRCh38Decoy.genome.fa.gz" \
-ibedfile=HMCPREF:/Strategy_HMCP_definition_Louella/MACS2_peaks_pooled.bams/reformatted.merged.sorted.hv.crc12.crc34.pooled.bams.bed.gz \
-ibamfile=${bam}  \
-ibaifile=${bam}.bai --destination=${outproject} \
-iextra_options=''")


dx select ${inproject} && $job

done #bam
echo
echo
done #cond

END

##############################################################################
### all pooled bam -- one per PC/IC, per disease group
### using per-disease-group specific peak set == 3 peak sets 


#DNAnexus folders
inproject=HMCPREF
outproject="HMCPREF:/Strategy_HMCP_definition_Louella/BAMS_dedup.pooled/"

: <<'END'

echo

##HV
bamlist="list.pooled.HV.5M.dedup.bams"
echo "list $bamlist"

for bam in $(cat $bamlist)
do
echo "in bam $bam"
bai=$(echo $bam | sed 's/.bam$/.bai/g')

# -iextra_options='' --> RPM/RPKMS using total reads per bam

job=$(echo "dx run bam_readcount --yes \
-ireference_fastagz="Genomes:/Homo_sapiens/NCBI/GRCh38Decoy/Sequence/WholeGenomeFasta/Homo_sapiens_NCBI_GRCh38Decoy.genome.fa.gz" \
-ibedfile=HMCPREF:/Strategy_HMCP_definition_Louella/MACS2_peaks_pooled.bams/reformatted.sorted.HMCP0110-HV-N48.trep48.crep48.macs2_peaks.narrowPeak.bed.gz \
-ibamfile=${bam} \
-ibaifile=${bai} -iextra_options='--min_overlap' --destination=${outproject}")

echo $job

#dx select ${inproject} && $job

done #bamlist
echo
echo

##CRC12
bamlist="list.pooled.CRC12.5M.dedup.bams"
echo "list $bamlist"

for bam in $(cat $bamlist)
do
echo "in bam $bam"
bai=$(echo $bam | sed 's/.bam$/.bai/g')

# -iextra_options='' --> RPM/RPKMS using total reads per bam
job=$(echo "dx run bam_readcount --yes \
-ireference_fastagz="Genomes:/Homo_sapiens/NCBI/GRCh38Decoy/Sequence/WholeGenomeFasta/Homo_sapiens_NCBI_GRCh38Decoy.genome.fa.gz" \
-ibedfile=HMCPREF:/Strategy_HMCP_definition_Louella/MACS2_peaks_pooled.bams/reformatted.sorted.HMCP0110-CRC12-N38.trep38.crep38.macs2_peaks.narrowPeak.bed.gz \
-ibamfile=${bam} \
-ibaifile=${bai} --destination=${outproject} \
-iextra_options=''")


dx select ${inproject} && $job

done #bamlist
echo
echo

##
bamlist="list.pooled.CRC34.5M.dedup.bams"
echo "list $bamlist"

for bam in $(cat $bamlist)
do
echo "in bam $bam"
bai=$(echo $bam | sed 's/.bam$/.bai/g')

# -iextra_options='' --> RPM/RPKMS using total reads per bam
job=$(echo "dx run bam_readcount --yes \
-ireference_fastagz="Genomes:/Homo_sapiens/NCBI/GRCh38Decoy/Sequence/WholeGenomeFasta/Homo_sapiens_NCBI_GRCh38Decoy.genome.fa.gz" \
-ibedfile=HMCPREF:/Strategy_HMCP_definition_Louella/MACS2_peaks_pooled.bams/reformatted.sorted.HMCP0110-CRC34-N19.trep19.crep19.macs2_peaks.narrowPeak.bed.gz \
-ibamfile=${bam}  \
-ibaifile=${bai} --destination=${outproject} \
-iextra_options='--min_map_quality'")


#dx select ${inproject} && $job

done #bamlist
echo
echo


END


