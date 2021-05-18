FROM continuumio/anaconda
WORKDIR ./
RUN conda install -c bioconda/label/cf201901 bedtools
COPY R/Install.R ./Install.R
COPY R/CalculateTMB.R ./CalculateTMB.R
COPY R/calcTMB.sh ./calcTMB.sh
RUN apt-get update
RUN apt-get -yq install build-essential
RUN conda install r=3.5.1
RUN Rscript ./Install.R
RUN chmod 755 calcTMB.sh
CMD bash
