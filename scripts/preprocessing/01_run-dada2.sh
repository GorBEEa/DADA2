#!/bin/sh

#SBATCH --job-name=01_dada2
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

#[1] /input dataset/, with the fastq.gz (the name of the samples
#    has to be present on the left and separated by an underscore.
#    (multiple underscores are OK as long as the name is on the left).
#    Example: GBP23040702M_16S_B96_R1.fastq.gz
#    Sample name will be GBP23040702M_16S_B96, which is good bc it will be an unique identifier
#    But maybe you want a cleaner one. Your decision!

#[2] /output dir/ Usually it should be in data/, since afterwards you will use it
#                 for statistical analysis
#                 Best option, tidy option

#[3] /name/ A common identifier to be sure that the output is the
#            correct one. You will thank us that :^)

#[4] /trim position/ The positions to trim, both at the left and the right. The numbers have
#                     to be separated by a comma. Example: 240 (forward), 210 (rev).
#                     WATCH OUT. If you trim too close to your read length, you will lose many reads.
#                     Coded right now for the paired end case. If this is not your case,
#                     say it and we will see what can we do.

#[5] /max expected error/ The tolerated threshold of maxEE. Too stringent, the reads don't pass. Too
#                         relaxed, the modeled error can be incorrect. Usually, a maxEE of 1,2 if the
#                         read quality is really good, or a 2,4.

#[6] /minimum overlap reads/ The minimum expected overlap of reads. The default is 15, but in case you fail to merge
#                            most of the reads, an option is to lower the value to see the incremental changes. Beware not to
#                            go below 8.

#[7] /pooling method/ This is optional, write 'pool' if you want dada2 to pool together all samples prior to sample inference.
#                     Write 'pseudo' to perform pseudo-pooling between individually processed samples (less computationally demanding).
#                     If you do not write anything default is no pooling.


# If your cluster works with modules, first you
# should activate them.
# module load gcc/4.9.0
# module load R/4.3.2-gfbf-2023a

module load Python/Python-3.10.9-Anaconda3-2023.03-1
module load Mamba/23.1.0-4

# If you have a mamba/conda environment.
# conda activate your_env
conda activate dada2

Rscript scripts/preprocessing/01_dada2-error-output.R \
        data/raw \
        data/dada2 \
        2023_16S_GorBEEa_prj \
        230,220 \
        2,6 \
        15

# In case you have multiple runs, simply run again the script with the values of interest. Example:

#Rscript scripts/preprocessing/1_dada2-error-output.R \
#        data/raw/4300 \
#        data/dada2 \
#        GorBEEa_prj_run4300 \
#        210,200 \
#        1,4 \
#        15

# In the 3_merge you can aggregate them!
