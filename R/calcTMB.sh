#!/bin/bash

: ${INPUT_PATH:="/parcel/data/in"}
: ${OUTPUT_PATH:="/parcel/data/out"}
CMD="Rscript /app/CalculateTMB.R --ucec=$INPUT_PATH/UCEC.rda --exomef=$INPUT_PATH/exome_hg38_vep.Rdata --covarf=$INPUT_PATH/gene.covar.txt --mutContextf=$INPUT_PATH/mutation_context_96.txt --TST170_panel=$INPUT_PATH/TST170_DNA_targets_hg38.bed --ref=$INPUT_PATH/GRCh38.d1.vd1.fa --output=$OUTPUT_PATH/tmb.pdf"

if [[ $# -eq 1 ]]
then
  if [[ $1 -eq "test" ]]
  then
    echo $CMD
    $CMD
  elif [[ $1 -eq "train" ]]
  then
    CMD="{$CMD} --train"
    echo $CMD
    $CMD
  elif [[ $1 -eq "helloworld" ]]
  then
    CMD="Rscript /app/CalculateTMB.R | tee $OUTPUT_PATH/help.txt"
    echo $CMD
    $CMD
  else
    echo "Unrecognised arg '{$1}'"
  fi
else
  echo "Usage: /calcTMB.sh (test|train|helloworld)"
fi