# Install BiocManager and Packages
Sys.setenv(TAR = "/bin/tar")
install.packages("devtools", repo="http://cran.rstudio.com/")
install.packages("futile.logger", repo="http://cran.rstudio.com/")
install.packages("optparse", repo="http://cran.rstudio.com/")
library(devtools);
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager", repo="http://cran.rstudio.com/")
BiocManager::install()
remotes::install_version("RSQLite", version = "2.2.5", repo="http://cran.rstudio.com/")
BiocManager::install(c("GenomicFeatures", "GenomicRanges", "limma"))

# Follow installation instructions here: https://github.com/bioinform/ecTMB#installation
devtools::install_github("bioinform/ecTMB"); #update all

# Install plotting dependencies
install.packages("reshape", repo="http://cran.rstudio.com/")
