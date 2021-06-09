FROM continuumio/anaconda
WORKDIR ./
RUN conda install -c bioconda/label/cf201901 bedtools
CMD mkdir app
COPY R/Install.R ./app/Install.R
COPY R/CalculateTMB.R ./app/CalculateTMB.R
COPY R/calcTMB.sh ./app/calcTMB
COPY R/HelloWorld.R ./app/HelloWorld.R
COPY R/HelloWorld.sh ./app/HelloWorld
COPY dist/csv-extractor-cli-*.tar.gz ./csv-extractor-cli.tar.gz
CMD mkdir static
RUN apt-get update
RUN apt-get -yq install build-essential
RUN conda install r=3.5.1
RUN Rscript ./app/Install.R
RUN chmod 755 ./app/calcTMB
RUN chmod 755 ./app/HelloWorld
ENV PATH "$PATH:/app"
RUN pip install csv-extractor-cli.tar.gz
CMD bash
