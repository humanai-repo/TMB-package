#!/usr/bin/env Rscript

library(ecTMB)
library(futile.logger)
library(optparse)
library(dplyr)
library(ggplot2)
library(reshape)

parser <- OptionParser()
parser <- add_option(parser, c("--ucec"), help = "Path to input UCEC.rda")
parser <- add_option(parser, c("--exomef"),
  help = "Path to input exome_hg38_vep.Rdata")
parser <- add_option(parser, c("--covarf"),
  help = "Path to input gene.covar.txt")
parser <- add_option(parser, c("--mut_contextf"),
  help = "Path to input mutation_context_96.txt")
parser <- add_option(parser, c("--tst_170_panel"),
  help = "Path to input TST170_DNA_targets_hg38.bed")
parser <- add_option(parser, c("--ref"),
  help = "Path to input GRCh38.d1.vd1.fa")
parser <- add_option(parser, c("--output"), help = "Path to output tmb.pdf")
parser <- add_option(parser, c("--earlyexit"),
  help = "Exit early to test initial processing",
  action = "store_true", default = FALSE)
parser <- add_option(parser, c("--train"),
  help = "Running training in addition to testing",
  action = "store_true", default = FALSE)
parser <- add_option(parser, c("--quiet"), help = "Quiet output",
  action = "store_true", default = FALSE)

args <- parse_args(parser)

if (! args$quiet) {
  flog.threshold(DEBUG)
}

flog.debug("Load ucec.rda")
load(args$ucec)

flog.debug("Split test samples")
set.seed(1002200)
sample_id_all <- UCEC_cli$sample
sample_id_train <-
  sample(sample_id_all,
    size = round(2 * length(sample_id_all) / 3), replace = F)
sample_id_test <- sample_id_all[!sample_id_all %in% sample_id_train]

# test data for panel TST 170
sample <-
  data.frame(SampleID = sample_id_test,
    BED = args$tst_170_panel, stringsAsFactors = FALSE)
test_data <-
  UCEC_mafs[UCEC_mafs$Tumor_Sample_Barcode %in% as.character(sample_id_test), ]

if (args$earlyexit) {
  flog.debug("Exiting Early")
  # Memory usage test. By this point the script will be using ~2G of memory.
  # Write an output and quit.
  write(length(SampleID_all), args$output)
  q()
}

flog.debug("Read testdata Panel")
testset_panel <-
  readData(test_data, args$exomef, args$covarf, args$mut_contextf, args$ref,
    samplef = sample)
flog.debug("Read Whole Exome Sequence")
# Use to calculate WES-TMB for test samples
testset_wes <- readData(test_data, args$exomef, args$covarf, args$mut_contextf,
  args$ref)

if (args$train) {
  flog.debug("Training samples")
  train_data <-
    UCEC_mafs[
      UCEC_mafs$Tumor_Sample_Barcode %in% as.character(SampleID_train), ]
  trainset <-
    readData(train_data, args$exomef, args$covarf, args$mutContextf, args$ref)

  flog.debug("Train model")
  mr_tri_prob_train <- getBgMRtri(trainset)
  trained_model <- fit_model(trainset, mr_tri_prob_train, cores = 8)
}

flog.debug("Calculate TMB")
# process time less than 1s.
tmbs <- pred_TMB(testset_panel, WES = testset_wes, cores = 1,
  params = trainedModel, mut.nonsil = T)

flog.debug("Output graph")
# plot the prediction.
p <- tmbs %>%
  melt(id.vars = c("sample", "WES_TMB")) %>%
  ggplot(
    aes(x = WES_TMB, y = value,
      color =
        factor(variable, levels = c("ecTMB_panel_TMB",  "count_panel_TMB")),
      group = factor(variable))) +
  geom_point() +
  geom_abline(slope = 1, intercept = 0) +
  scale_x_continuous(trans = "log2") +
  scale_y_continuous(trans = "log2") +
  theme_bw() +
  theme(panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()) +
  theme(legend.title = element_blank()) +
  labs(x = "TMB defined by WES",
    y = sprintf("Predicted TMB from panel: TST170"))

pdf(args$output)
print(p)
dev.off()