#!/bin/sh

#SBATCH --job-name=03_add_taxonomy
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
## ~~ Trimming, error generation and DADA2 run ~~ ##

#Trimming of the reads (and filtering with maxEE),
#generation of an error model whit the probabilities
#transitions between bases (A -> T) and dada2 algorithm.
#BEFORE continue the pipeline, PLEASE, check the error plot
#(a .pdf generated in the output dir).

## ARGS ##

#[1] /seqtab/ 
#   seqtab with chimeras removed.

#[2] /table/ 
#   tsv file with analysis information obtained in previous step.

#[3] /output dir/ 
#   Directory output, usually data (a subdirectory will be created).

#[4] /name/ 
#   A common identifier to be sure that the output is the
#   correct one. You will thank us that :^)

#[5] /Taxonomy db/ 
#   Here you have to put your database[s] for classification.
#   if using dada's assignTaxonomy() and addSpecies() functions, put your 2 databases separated by a comma
#   if using only assignTaxonomy(), put your database   
#   if using DECIPHER, the db has to be downloaded from http://www2.decipher.codes/Downloads.html and put here

#[6] /Taxonomy classification method/ 
#   write 'decipher' if you want to use DECIPHER's IdTaxa() to classify
#   write 'unite' if you are following ITS fungi pipeline
#   write 'dada' if you want to use the classifier included in dada2

#[7] /Confidence level of classification (DECIPHER) or minBoot (dada2)/
#   DECIPHER (default 60):       
#       Numeric specifying the confidence at which to truncate
#       the output taxonomic classifications. Lower values of threshold
#       will classify deeper into the taxonomic tree at the expense of accuracy,
#       and vice-versa for higher values of threshold.
#
#   UNITE and DADA2 (default 50):
#       The minimum bootstrap confidence for assigning a taxonomic level.

# If your cluster works with modules, first you
# should activate them.
#module load gcc/4.9.0
#module load R/4.3.2-gfbf-2023a

module load Python/Python-3.10.9-Anaconda3-2023.03-1
module load Mamba/23.1.0-4

# If you have a mamba/conda environment.
# conda activate your_env
conda activate dada2

# 1. Example with DECIPHER
Rscript scripts/preprocessing/03_add-taxonomy.R \
    data/dada2/02_nochimera_mergeruns/2023_16S_GorBEEa_prj/2023_16S_GorBEEa_prj_seqtab_final.rds \
    data/dada2/02_nochimera_mergeruns/2023_16S_GorBEEa_prj/2023_16S_GorBEEa_prj_track_analysis_final.tsv \
    data/dada2 \
    2023_16S_GorBEEa_prj \
    data/assign_tax/SILVA_SSU_r138_2019.RData \
    decipher \
    60

# 2. Example with dada2 classifier (commented to avoid running it)
# Rscript scripts/preprocessing/03_add-taxonomy.R \
#     data/dada2/02_nochimera_mergeruns/2023_16S_GorBEEa_prj/2023_16S_GorBEEa_prj_seqtab_final.rds \
#     data/dada2/02_nochimera_mergeruns/2023_16S_GorBEEa_prj/2023_16S_GorBEEa_prj_track_analysis_final.tsv \
#     data/dada2 \
#     2023_16S_GorBEEa_prj \
#     data/assign_tax/your_database_training.fasta,data/assing_tax/your_database_species.fasta \
#     dada \
#     50

# 3. Example with UNITE classifier (commented to avoid running it)
# Rscript scripts/preprocessing/03_add-taxonomy.R \
#     data/dada2/02_nochimera_mergeruns/2023_ITS_GorBEEa_prj/2023_ITS_GorBEEa_prj_seqtab_final.rds \
#     data/dada2/02_nochimera_mergeruns/2023_ITS_GorBEEa_prj/2023_ITS_GorBEEa_prj_track_analysis_final.tsv \
#     data/dada2 \
#     2023_ITS_GorBEEa_prj \
#     data/assign_tax/your_database_training.fasta,data/assing_tax/your_database_species.fasta \
#     unite \
#     50