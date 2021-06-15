FROM continuumio/anaconda
WORKDIR /
RUN conda install -c bioconda/label/cf201901 bedtools
RUN mkdir app
COPY R/Install.R ./app/Install.R
COPY R/CalculateTMB.R ./app/CalculateTMB.R
COPY R/calcTMB.sh ./app/calcTMB
RUN mkdir static
RUN apt-get update
RUN apt-get -yq install build-essential
RUN conda install r=3.5.1
RUN Rscript ./app/Install.R
RUN chmod 755 ./app/calcTMB
ENV PATH "$PATH:/app"
CMD bash
