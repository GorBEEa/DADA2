#!/bin/sh

#SBATCH --job-name=02_merge_nochimera
#SBATCH --error=data/logs/%x-%j.err
#SBATCH --output=data/logs/%x-%j.out

#SBATCH --partition=general # This is the default partition
#SBATCH --qos=regular
#SBATCH --cpus-per-task=2
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

#[1] /seqtables/ each of them separated by a comma.
#                The path should be the complete one. With many seqtables,
#                first they are merged and then bimeras are tested.

#[2] /output dir/ Directory output, usually data (a subdirectory will be created).

#[3] /name/ A common identifier to be sure that the output is the
#            correct one. You will thank us that :^)

#[4] /trim length/ After all the processing, some unespecific amplified reads still are present in the samples.
#                   Time to cut them down. Specify with a range which read you want to keep (Example: 400,450)

#[5] /chimera removal method/ One of 'consensus' (default), 'pooled' or 'per-sample'
#                             If you used pooling in dada inference step you should use 'pooled' method

# If your cluster works with modules, first you
# should activate them.
# module load gcc/4.9.0
# module load R/4.3.2-gfbf-2023a

module load Python/Python-3.10.9-Anaconda3-2023.03-1
module load Mamba/23.1.0-4

# If you have a mamba/conda environment.
# conda activate your_env
conda activate dada2

# remember, this is an example: you should change [1,3,4] at least

Rscript scripts/preprocessing/02_chimerarem_merge.R \
                    data/dada2/01_errors-output/2023_16S_GorBEEa_prj/2023_16S_GorBEEa_prj_seqtab.rds \
                    data/dada2 \
                    2023_16S_GorBEEa_prj \
                    240,450 \
                    consensus

# If you have multple seqtabs, it should be written like this:

#data/1_errors-output/GorBEEa_project/GorBEEa_2023_1,data/1_errors-output/GorBEEa_project/GorBEEa_2023_2 ...
