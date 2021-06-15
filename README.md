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
calcTMB.sh is the main entry script. The expected mountpoints are the
[Parcel](https://www.oasislabs.com/) mountpoints: /parcel/data/in for
input files and /parcel/data/out for output files. calcTMB.sh has 3
modes: `helloworld` just outputs the help text, `test` applies the
prebuilt model, `train` builds a new model and applies it.

```bash
./calcTMB.sh
Usage: /calcTMB.sh (test|train|helloworld)
```

The easiest way to run from docker:

```bash
docker run --rm -v $WORKING_DATA:/parcel/data/in -v $WORKING_DATA:/parcel/data/out humansimon/ectmb calcTMB test
```

Or invoking R directly:
```bash
docker run --rm \
  -v $WORKING_DATA:/parcel/data/in \
  -v $WORKING_DATA:/parcel/data/out \
  humansimon/ectmb \
  Rscript /app/CalculateTMB.R \
    --ucec=/parcel/data/in/UCEC.rda \
    --exomef=/parcel/data/in/exome_hg38_vep.Rdata \
    --covarf=/parcel/data/in/gene.covar.txt \
    --mutContextf=/parcel/data/in/mutation_context_96.txt \
    --TST170_panel=/parcel/data/in/TST170_DNA_targets_hg38.bed \
    --ref=/parcel/data/in/GRCh38.d1.vd1.fa \
    --output=/parcel/data/out/tmb.pdf
```

Full documentation can be printed by calling help.

```bash
RScript ./R/CalculateTMB.R --help

Usage: R/CalculateTMB.R [options]


Options:
        -h, --help
                Show this help message and exit

        --ucec=UCEC
                Path to input UCEC.rda

        --exomef=EXOMEF
                Path to input exome_hg38_vep.Rdata

        --covarf=COVARF
                Path to input gene.covar.txt

        --mutContextf=MUTCONTEXTF
                Path to input mutation_context_96.txt

        --TST170_panel=TST170_PANEL
                Path to input TST170_DNA_targets_hg38.bed

        --ref=REF
                Path to input GRCh38.d1.vd1.fa

        --output=OUTPUT
                Path to output tmb.pdf

        --earlyexit
                Exit early to test initial processing

        --train
                Running training in addition to testing

        --quiet
                Quiet output
```

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

To make a docker image with no deps all inputs can be bootstraped.

```bash
docker build --tag ectmb-nodeps -f Dockerfile.nodeps .
```

```bash
# List runing docker image to get the Image ID
docker images

docker tag $IMAGE_ID $DOCKERHUB_USERNAME/ectmb-nodeps:latest

docker login --username=$DOCKERHUB_USERNAME

docker push $DOCKERHUB_USERNAME/ectmb-nodeps
```

The nodeps Docker image has two alternative entry points, one requiring only
an output directory, the other no mount points.

```bash
docker run --rm -v $WORKING_DATA:/parcel/data/out humansimon/ectmb-nodeps calcTMBNoDeps test
```

```bash
docker run --rm -v $WORKING_DATA:/parcel/data/out humansimon/ectmb-nodeps calcTMBNoMount test
```

## Caveats
This package has been built as a proof of concept only and has not been
sufficiently tested for a production setting.