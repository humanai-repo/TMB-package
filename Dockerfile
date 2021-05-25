FROM continuumio/anaconda
WORKDIR ./
RUN conda install -c bioconda/label/cf201901 bedtools
COPY R/Install.R ./Install.R
COPY R/CalculateTMB.R ./CalculateTMB.R
COPY R/calcTMB.sh ./calcTMB.sh
CMD mkdir static
COPY working-data/exome_hg38_vep.Rdata ./static/exome_hg38_vep.Rdata
COPY working-data/GRCh38.d1.vd1.fa ./static/GRCh38.d1.vd1.fa
COPY working-data/UCEC.rda ./static/UCEC.rda
RUN apt-get update
RUN apt-get -yq install build-essential
RUN conda install r=3.5.1
RUN Rscript ./Install.R
RUN chmod 755 calcTMB.sh
CMD bash
