#!/bin/bash

blacklist="/home/louellavasquez/HMCP0110_FEAT_DEFINITIONS/sorted.hg38.blacklist.bed"

datadir="/home/louellavasquez/HMCP0110_FEAT_DEFINITIONS/DATA/BAMS"
inbam="${datadir}/CEG68-119-27PC_S6_L00.bml.GRCh38.karyo.deduplicated.bam"
refbam="${datadir}/CEG68-123-69PC_S6_L00.bml.GRCh38.karyo.deduplicated.bam"


plotFingerprint -b $refbam $inbam -plot fingerprint.genomewide.png --JSDsample $refbam \
--outQualityMetrics out.plotFingerprint.QCMetrics.txt --blackListFileName $blacklist --labels ref in # \
#--region chr10