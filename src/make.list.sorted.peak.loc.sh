#!/bin/bash

key="/home/louellavasquez/HMCP0110_FEAT_DEFINITIONS/lv.reformat_pheno_tab_for_biogroups.txt"
datadir="/home/louellavasquez/HMCP0110_FEAT_DEFINITIONS/DATA/HMCP0110_macs2.peaks_per.donor/SORTED_BEDS"

group=$1
#group="HV"
# 38 CRC1-2
# 19 CRC3-4
# 48 HV

echo -n > list.$group.sorted.peak.file.loc.txt
for row in $(sed 1d $key | awk -v GRP="$group" '$3==GRP' | cut -f2)
do
    ls $datadir/*.narrowPeak | grep $row >>  list.$group.sorted.peak.file.loc.txt
    
done
