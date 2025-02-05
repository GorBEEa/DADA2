#!/bin/sh

#SBATCH --job-name=00_qprofile
#SBATCH --error=data/logs/%x-%j.err
#SBATCH --output=data/logs/%x-%j.out

#SBATCH --partition=general # This is the default partition
#SBATCH --qos=regular
#SBATCH --cpus-per-task=1
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=10:00:00
#SBATCH --mem=24000

# Time and memory consumption estimates are orientative. Please adjust them according to you requirments.

### DADA2 pipeline ######
## ~~ Q profile ~~ ##

# The script generates a .pdf with the Qscore profiles
# from your first 9 samples, in order to be able to define
# the trimming length of the reads (both forward and reverse).

## ARGS ##

#[1] /input dataset/, with the fastq.gz (the name of the samples
#    has to be present on the left and separated by an underscore.
#    (multiple underscores are OK as long as the name is on the left).
#    Examples: sample4582515-ITS1-gorbea_R1.fastq.gz
#              GBP23040702M_16S_B96_R2.fastq.gz

#[2] /output dir/ A directory in which all the output will be stored.
#                 If you have copied the github project, you should have
#                 an data dir. in which it should be copied

#[3] /name/ A common identifier to keep track of the output
#           You will thank us that :^)

# If your cluster works with modules, first you
# should activate them.
#module load gcc/4.9.0
#module load R/4.3.2-gfbf-2023a

module load Python/Python-3.10.9-Anaconda3-2023.03-1
module load Mamba/23.1.0-4

# If you have a mamba/conda environment.
# conda activate your_env
conda activate dada2

Rscript scripts/preprocessing/00_qscore.R \
        data/raw \
        data/dada2 \
        2023_16S_GorBEEa_prj

# IMPORTANT POINT !!!!!
# If you want to save the ouptput//errors in a logfile, simply add
# > logout.txt 2> logout_err.txt to have all the info

# As it is written now, you can also work locally. 
# Executing this script locally will make a call to scripts/preprocessing/00_qscore.R
# and output directly the messages in the console
# The same applies to all the other scripts!
