#!/bin/bash
#
# Wrapper to run `CalculateTMB.R` in test, train or help mode.

set -ex

: ${INPUT_PATH:="/parcel/data/in"}
: ${OUTPUT_PATH:="/parcel/data/out"}
CMD="Rscript /app/CalculateTMB.R --ucec=$INPUT_PATH/UCEC.rda --exomef=$INPUT_PATH/exome_hg38_vep.Rdata --covarf=$INPUT_PATH/gene.covar.txt --mut_contextf=$INPUT_PATH/mutation_context_96.txt --tst_170_panel=$INPUT_PATH/TST170_DNA_targets_hg38.bed --ref=$INPUT_PATH/GRCh38.d1.vd1.fa --output=$OUTPUT_PATH/tmb.pdf"

if [[ $# -ne 1 ]]; then
  echo "Usage: /calcTMB.sh (test|train|helloworld)"
  exit 1
fi

if [[ "$1" = "test" ]]
then
  $CMD
elif [[ "$1" = "train" ]]
then
  CMD="$CMD --train"
  $CMD
elif [[ "$1" = "helloworld" ]]
then
  Rscript /app/CalculateTMB.R --help | tee $OUTPUT_PATH/help.txt
else
  echo "Unrecognised arg '$1'"
fi