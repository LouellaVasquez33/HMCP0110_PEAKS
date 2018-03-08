#!/bin/bash

list=$1
list=list.HV.sorted.peak.file.loc.txt

ofile="large.peaks.in.$list"
echo -n > $ofile
for peak in $(cat $list)
do
echo "#${peak}" >> $ofile     
cut -f1-3 $peak | awk '{print $0,$3-$2}' | sort -rnk4,4 | head -n100 >> $ofile

done
