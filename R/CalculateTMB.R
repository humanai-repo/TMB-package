#!/usr/bin/env Rscript

library(ecTMB)
library(futile.logger)
library("optparse")

parser <- OptionParser()
parser <- add_option(parser, c("--ucec"), help="Path to input UCEC.rda")
parser <- add_option(parser, c("--exomef"), help="Path to input exome_hg38_vep.Rdata")
parser <- add_option(parser, c("--covarf"), help="Path to input gene.covar.txt")
parser <- add_option(parser, c("--mutContextf"), help="Path to input mutation_context_96.txt")
parser <- add_option(parser, c("--TST170_panel"), help="Path to input TST170_DNA_targets_hg38.bed")
parser <- add_option(parser, c("--ref"), help="Path to input GRCh38.d1.vd1.fa")
parser <- add_option(parser, c("--output"), help="Path to output tmb.pdf")
parser <- add_option(parser, c("--earlyexit"), help="Exit early to test initial processing", action="store_true", default=FALSE)
parser <- add_option(parser, c("--train"), help="Running training in addition to testing", action="store_true", default=FALSE)
parser <- add_option(parser, c("--quiet"), help="Quiet output", action="store_true", default=FALSE)

args <- parse_args(parser)

if(! args$quiet) {
  flog.threshold(DEBUG)
}

flog.debug("Load ucec.rda")
load( args$ucec )

flog.debug("Split test samples")
set.seed(1002200)
SampleID_all   = UCEC_cli$sample
SampleID_train = sample(SampleID_all, size = round(2 * length(SampleID_all)/3), replace = F)
SampleID_test  = SampleID_all[!SampleID_all %in% SampleID_train]

## test data for panel TST 170
sample         = data.frame(SampleID = SampleID_test, BED = args$TST170_panel, stringsAsFactors = FALSE)
testData       = UCEC_mafs[UCEC_mafs$Tumor_Sample_Barcode %in% as.character(SampleID_test),]

if(args$earlyexit) {
  flog.debug("Exiting Early")
  # Memory usage test. By this point the script will be using ~2G of memory. To test is mem usage 
  # Write an output and quite.
  write(length(SampleID_all), args$output)
  q()
}

flog.debug("Read testdata Panel")
testset_panel  = readData(testData, args$exomef, args$covarf, args$mutContextf, args$ref, samplef = sample)
flog.debug("Read Whole Exome Sequence")
testset_WES    = readData(testData, args$exomef, args$covarf, args$mutContextf, args$ref)  ## to calculate WES-TMB for test samples

if(args$train) {
  flog.debug("Training samples")
  trainData      = UCEC_mafs[UCEC_mafs$Tumor_Sample_Barcode %in% as.character(SampleID_train),]
  trainset       = readData(trainData, args$exomef, args$covarf, args$mutContextf, args$ref)

  flog.debug("Train model")
  MRtriProb_train= getBgMRtri(trainset)
  trainedModel   = fit_model(trainset, MRtriProb_train, cores = 8)
}

flog.debug("Calculate TMB")
## process time less than 1s. 
TMBs          =  pred_TMB(testset_panel, WES = testset_WES, cores = 1,
                        params = trainedModel, mut.nonsil = T)

flog.debug("Output graph")                        
## plot the prediction.    
library(dplyr)
library(ggplot2)
library(reshape)

p <- TMBs %>% melt(id.vars = c("sample","WES_TMB")) %>% 
  ggplot( aes(x = WES_TMB, y = value,  color = factor(variable, levels = c("ecTMB_panel_TMB",  "count_panel_TMB")), 
              group = factor(variable))) + 
  geom_point() +
  geom_abline(slope = 1, intercept = 0) + 
  scale_x_continuous(trans='log2') +
  scale_y_continuous(trans='log2') +
  theme_bw() +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) +
  theme(legend.title=element_blank()) +
  labs(x = "TMB defined by WES", y = sprintf("Predicted TMB from panel: TST170"))

pdf(args$output)
print(p)
dev.off()