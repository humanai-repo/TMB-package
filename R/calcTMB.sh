#!/bin/bash

if [[ $# -eq 7 ]]
then
  CMD="Rscript ./CalculateTMB.R $1 $2 $3 $4 $5 $6 $7"
  echo $CMD
  $CMD
elif [[ $# -eq 0 ]]
then
  INPUT_PATH="/parcel/data/in"
  OUTPUT_PATH="/parcel/data/out"
  CMD="Rscript ./CalculateTMB.R $INPUT_PATH/UCEC.rda $INPUT_PATH/exome_hg38_vep.Rdata $INPUT_PATH/gene.covar.txt $INPUT_PATH/mutation_context_96.txt $INPUT_PATH/TST170_DNA_targets_hg38.bed $INPUT_PATH/GRCh38.d1.vd1.fa $OUTPUT_PATH/tmb.pdf"
  echo $CMD
  $CMD
else
  echo "Expected all files to be specified or no files to be specified (defaults)."
  CMD="Rscript ./CalculateTMB.R"
  $CMD
fi