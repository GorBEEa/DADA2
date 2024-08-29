#!/bin/sh

#SBATCH --job-name=O4_clustering
#SBATCH --error=data/logs/%x-%j.err
#SBATCH --output=data/logs/%x-%j.out

#SBATCH --partition=general # This is the default partition
#SBATCH --qos=regular
#SBATCH --cpus-per-task=48
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=10:00:00
#SBATCH --mem=24000

### DADA2 pipeline ######
###### clustering ######

## ARGS ##

#[1] /seqtab/ seqtab you want to cluster.

#[2] /clustering identity/ clustering identity in a 0-100 scale.

#[3] /output directory/ directory where output files should be written.

#[4] /name/ A common identifier to be sure that the output is the
#            correct one. You will thank us that :^)

module load R/4.3.2-gfbf-2023a

# remember, this is an example

Rscript scripts/preprocessing/04_ASV-clustering.R \
    data/dada2/02_nochimera_mergeruns/blanes_project/blanes_project_seqtab_final.rds \
    97 \
    data/dada2/ \
    blanes_project
