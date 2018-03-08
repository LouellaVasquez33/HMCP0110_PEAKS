#!/bin/bash
#bash /home/louellavasquez/dx-toolkit/environment




##########################################
#get PC (HMCP) and IC (input) bams !!
# subsampled-5M deduplicated bams !!

folders=("CEGX_Run461:/subsampl_005M_CEGX_Run461-12345678" \
	     "CEGX_Run462:/subsampl_005M_CEGX_Run462-12345678" \
	     "CEGX_Run463:/subsampl_005M_CEGX_Run463-12345678" \
	     "CEGX_Run464:/subsampl_005M_CEGX_Run464-12345678" \
	     "CEGX_Run465:/subsampl_005M_CEGX_Run465-12345678")

for dir in "${folders[@]}"
do
    echo $dir
    hname=$(echo $dir | cut -d/ -f1)
    name=$(echo $dir | sed 's/:\//_/g')
: <<'END'
    dx find data --path $dir | \
  	cut -d" " -f7- | sed -e 's/^[ \t]*//' | cut -d" " -f1 | grep '\005M.ssamp.deduplicated.bam$' | \
  	awk -v LEFT="$hname" '{print LEFT$0}' > list.5M.dedup.bams.$name
END

done

##########################################
#get PC (HMCP) and IC (input) bams !!
# deduplicated bams !!

folders=( "CEGX_Run461:/CEGX_Run461-12345678" \
"CEGX_Run462:/CEGX_Run462-12345678" \
"CEGX_Run463:/CEGX_Run463-12345678" \
"CEGX_Run464:/CEGX_Run464-12345678" \
"CEGX_Run465:/CEGX_Run465-12345678")


for dir in "${folders[@]}"
do
    echo $dir
    hname=$(echo $dir | cut -d/ -f1)
    name=$(echo $dir | sed 's/:\//_/g')

 : <<'END'
    dx find data --path $dir | \
	cut -d" " -f7- | sed -e 's/^[ \t]*//' | cut -d" " -f1 | grep '\deduplicated.bam$' | \
	awk -v LEFT="$hname" '{print LEFT$0}' > list.dedup.bams.$name
END

done

echo ">>> finished making list of bams from DNAnexus"
echo


#####################################################################
#split bam list of each project into per group: HV, CRC1-2, CRC3-4
#make list of all 5M bams from different nexus projects and group bams together into HV, CRC1-2, CRC3-4

lists=("list.HV.peak.file.loc.txt" "list.CRC1-2.peak.file.loc.txt" "list.CRC3-4.peak.file.loc.txt")
projects=(CEGX_Run461 CEGX_Run462 CEGX_Run463 CEGX_Run464 CEGX_Run465)

 : <<'END'
for list in "${lists[@]}"
do
echo ">>> list $list"
name=$(echo $list | cut -d. -f2)

cat $list | awk -F/ '{print $NF}' | cut -d_ -f1 > tmp.PC.list
cat tmp.PC.list | sed 's/PC/IC/g'  > tmp.IC.list


echo -n > list.$name.PC.5M.dedup.bams.from.DNAnexus.txt
echo -n > list.$name.IC.5M.dedup.bams.from.DNAnexus.txt

for proj in "${projects[@]}"
do
		proj="list.5M.dedup.bams.${proj}_subsampl_005M_${proj}-12345678"
		echo $proj
		
		#making list for PC bams
    grep -f tmp.PC.list $proj >> list.$name.PC.5M.dedup.bams.from.DNAnexus.txt
		
		#making list for IC bams
    grep -f tmp.IC.list $proj >> list.$name.IC.5M.dedup.bams.from.DNAnexus.txt

done

done
rm tmp.PC.list
rm tmp.IC.list

END


#####################################################################
#split bam list of each project into per group: HV, CRC1-2, CRC3-4
#make list of all full depth bams from different nexus projects and group bams together into HV, CRC1-2, CRC3-4

lists=("list.HV.peak.file.loc.txt" "list.CRC1-2.peak.file.loc.txt" "list.CRC3-4.peak.file.loc.txt")
projects=(CEGX_Run461 CEGX_Run462 CEGX_Run463 CEGX_Run464 CEGX_Run465)


for list in "${lists[@]}"
do
echo ">>> list $list"
name=$(echo $list | cut -d. -f2)

cat $list | awk -F/ '{print $NF}' | cut -d_ -f1 > tmp.PC.list
cat tmp.PC.list | sed 's/PC/IC/g'  > tmp.IC.list


echo -n > list.$name.PC.dedup.bams.from.DNAnexus.txt
echo -n > list.$name.IC.dedup.bams.from.DNAnexus.txt

for proj in "${projects[@]}"
do
		proj="list.dedup.bams.${proj}_${proj}-12345678"
		echo $proj
		
		#making list for PC bams
    grep -f tmp.PC.list $proj >> list.$name.PC.dedup.bams.from.DNAnexus.txt
		
		#making list for IC bams
    grep -f tmp.IC.list $proj >> list.$name.IC.dedup.bams.from.DNAnexus.txt

done

done
rm tmp.PC.list
rm tmp.IC.list















