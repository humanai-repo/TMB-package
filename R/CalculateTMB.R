library(ecTMB)

args = commandArgs(trailingOnly=TRUE)
if (length(args)!=7) {
  stop("Expected Ags: ucec.rda hg38ExomeFile geneProperties mutationContextsTxt mutationtContextsBed grch38.d1 ouput.png.n", call.=FALSE)
}

load(args[1])
exomef                 = args[2]  #### hg38 exome file
covarf                 = args[3]   ### gene properties
mutContextf            = args[4]  ### 96 mutation contexts
TST170_panel           = args[5]  ### 96 mutation contexts
ref                    = args[6]
output 				   = args[7]



set.seed(1002200)
SampleID_all   = UCEC_cli$sample
SampleID_train = sample(SampleID_all, size = round(2 * length(SampleID_all)/3), replace = F)
SampleID_test  = SampleID_all[!SampleID_all %in% SampleID_train]

## test data for panel TST 170
sample         = data.frame(SampleID = SampleID_test, BED = TST170_panel, stringsAsFactors = FALSE)
testData       = UCEC_mafs[UCEC_mafs$Tumor_Sample_Barcode %in% as.character(SampleID_test),]
testset_panel  = readData(testData, exomef, covarf, mutContextf, ref, samplef = sample)
testset_WES    = readData(testData, exomef, covarf, mutContextf, ref)  ## to calculate WES-TMB for test samples


## process time less than 1s. 
TMBs          =  pred_TMB(testset_panel, WES = testset_WES, cores = 1,
                        params = trainedModel, mut.nonsil = T)
                        
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

pdf(output)
print(p)
dev.off()