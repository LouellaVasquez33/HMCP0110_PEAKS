#!/bin/bash

ref="merged.sorted.hv.crc12.crc34.pooled.bams.bed"
query="hg38.cpg.bed"

#ref="chr20.only_merged.sorted.hv.crc12.crc34.pooled.bams.bed"
#query="chr20.only_hg38.cpg.bed"

#which peaks overlap CpG sites -e 1
#bedextract $ref $query > has.CpG.merged.sorted.hv.crc12.crc34.pooled.bams.bed

#count how many CpGs per peak
#bedmap --echo --count --delim "\t" $ref $query > count.CpG.in.$ref


#assign CpG to peak - to count 
#closest-features --dist --closest --delim "\t" $query $ref | awk '$8==0' > peak.to.$query



#remove peaks with no CpGs
#remove blacklist regions
nocpg=/home/louellavasquez/HMCP0110_FEAT_DEFINITIONS/no.CpG.in.merged.sorted.hv.crc12.crc34.pooled.bams.bed 
blacklist=/home/louellavasquez/HMCP0110_FEAT_DEFINITIONS/sorted.hg38.blacklist.bed

#bedops --not-element-of 1 $ref $nocpg $blacklist


#assign gene to peaks plus distance
genedb=/home/louellavasquez/HMCP0110_FEAT_DEFINITIONS/REFERENCES_ANNOTATIONS/input/gencode.v25.gene.bed
enhdb=/home/louellavasquez/HMCP0110_FEAT_DEFINITIONS/REFERENCES_ANNOTATIONS/input/genehancer.v1.bed

closest-features --dist --closest --delim "\t" $ref $genedb > genes.to.$ref
closest-features --dist --closest --delim "\t" $ref $enhdb > enhancer.to.$ref