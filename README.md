# TMB-package
 A docker image for calculating Tumour Mutation Burden.


[Yao et al's](https://www.nature.com/articles/s41598-020-61575-1) proposes a
method for calculating Tumour Mutation Burden. They released the
[ecTMB](https://github.com/bioinform/ecTMB) code into the
[Bioinformatics Repo](https://github.com/bioinform).

This package includes scripts to build a Docker image including ecTMB and
all its dependencies, and bundles them with a script that calculates the
Tumour Mutation Burden of a mounted file.

The resulting image is sealed for execution within a sandbox.

We've taken the original ecTMB example and backed it into the image. 

## Usage
calcTMB.sh is the entry script. Input files can either be provided as args
or default to mountpoints. The expected mountpoints are the
[Parcel](https://www.oasislabs.com/) mountpoints: /parcel/data/in for
input files and /parcel/data/out for ouput files.

```bash
./calcTMB.sh
```

The first 6 args are paths to input files. EcTMB provides downloadable 
[example and reference data](https://github.com/bioinform/ecTMB#download-example-and-reference-data). The final argument is a path to
an output pdf.

```bash
./calcTMB.sh "./ecTMB_data/example/UCEC.rda" \
"./ecTMB_data/references/exome_hg38_vep.Rdata" \
"./ecTMB_data/references/gene.covar.txt" \
"./ecTMB_data/references/mutation_context_96.txt" \
"./ecTMB_data/references/TST170_DNA_targets_hg38.bed" \
"./GRCh38.d1.vd1.fa" \
"./tmb.pdf"
```

The easiest way to run from docker is to launch the docker image with a flat
input directory containing the example input files (listed above) mounted to
/parcel/data/in and an output directory to /parcel/data/out.

Peak memory for the docker image was measured at 7.5G (make sure enough RAM/swap
is allocated).

## Build
Run (note docker build takes 20 minutes on Mac book pro).

```bash
docker build --tag ectmb .
```

To push to docker hub

```bash
# List runing docker image to get the Image ID
docker images

docker tag $IMAGE_ID $DOCKERHUB_USERNAME/ectmb:latest

docker login --username=$DOCKERHUB_USERNAME

docker push $DOCKERHUB_USERNAME/ectmb
```

## Caveats
This package has been built as a proof of concept only and has not been
sufficiently tested for a production setting.