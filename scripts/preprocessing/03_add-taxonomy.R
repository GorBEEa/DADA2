## ------------------------------------------------------------------------
#This script adds taxonomy to each of the inferred ASVs

library(dada2)
library(tidyverse) ; packageVersion("tidyverse")
library(viridisLite) ; packageVersion("viridisLite")

cat(paste0('\n',"You are using DADA2 version ", packageVersion('dada2'),'\n'))

cat('################################\n\n')

args <- commandArgs(trailingOnly = TRUE)

seqtab.nochim <- args[1]
track.analysis <- args[2]
output <- args[3]
name <- args[4]
tax_db <- strsplit(args[5], ",")[[1]]
method <- args[6]
threshold <- as.integer(args[7])

dir.create(file.path(output, "03_taxonomy"), showWarnings = FALSE)
dir.create(file.path(output, "03_taxonomy", name), showWarnings = FALSE)

output <- paste0(output,"/03_taxonomy/",name,"/")

# Assign taxonomy (general)
set.seed(42) #random  generator necessary for reproducibility

seqtab.nochim <- readRDS(seqtab.nochim)
track.analysis <- read_tsv(track.analysis)

if (grepl('[Dd]ecipher|DECIPHER', method)){ # use decipher

library(DECIPHER)
cat(paste0("You are using DECIPHER version ", packageVersion('DECIPHER'),'\n\n'))

dna <- DNAStringSet(getSequences(seqtab.nochim)) # Create a DNAStringSet from the ASVs

if (grepl('\\.RData$', tax_db[1])){
  load(tax_db[1])
} else if (grepl('\\.rds$',tax_db[1])){
  trainingSet <- readRDS(tax_db[1])
}

if (is.na(threshold)){
    threshold <- 60
}

ids <- IdTaxa(dna,
             trainingSet,
             strand = "top",
             processors = NULL,
             verbose = FALSE,
             threshold = threshold)

ranks <- c("domain", "phylum", "class", "order", "family", "genus", "species") # ranks of interest

# Convert the output object of class "Taxa" to a matrix analogous to the output from assignTaxonomy
taxid <- t(sapply(ids, function(x) {
        m <- match(ranks, x$rank)
        taxa <- x$taxon[m]
        taxa[startsWith(taxa, "unclassified_")] <- NA
        taxa
}))

colnames(taxid) <- ranks; rownames(taxid) <- getSequences(seqtab.nochim)

####
####

} else if (grepl('[Uu]nite|UNITE', method)){ # use ITS fungi pipeline

 if (is.na(threshold)){
   threshold <- 50
  }

 cat('# The ITS fungi pipeline will be used\n')
  taxid <- assignTaxonomy(seqtab.nochim,
                        tax_db[1], 
                        multithread=TRUE,
                        tryRC = TRUE)
  cat('# Taxonomy assigned to genus level\n')
  
  #if (!is.na(tax_db[2])) { # add species level if db available
   # taxid <- addSpecies(taxid, 
    #                    tax_db[2], 
     #                   verbose=TRUE, 
      #                  allowMultiple=3)
    #cat('\n# Taxonomy assigned to species level\n')
  #}
#}
##########
##########

} else { # use regular dada2 classificator
  
  if (is.na(threshold)){
   threshold <- 50
  }

  cat('# The taxonomic classification included in dada2 will be used\n')
  taxid <- assignTaxonomy(seqtab.nochim,
                        tax_db[1], 
                        multithread=TRUE,
                        minBoot=threshold)
  cat('# Taxonomy assigned to genus level\n')
  
  if (!is.na(tax_db[2])) { # add species level if db available
    taxid <- addSpecies(taxid, 
                        tax_db[2], 
                        verbose=TRUE, 
                        allowMultiple=3)
    cat('\n# Taxonomy assigned to species level\n')
  }
}

### LJ added
# giving our seq headers more manageable names (ASV_1, ASV_2...)
asv_seqs <- colnames(seqtab.nochim)
asv_headers <- vector(dim(seqtab.nochim)[2], mode="character")

for (i in seq_len(dim(seqtab.nochim)[2])) {
  asv_headers[i] <- paste(">ASV", i, sep="_")
}

# Above the solution provided by copilot. Below my code
#for (i in 1:dim(seqtab.nochim)[2]) {
#  asv_headers[i] <- paste(">ASV", i, sep="_")
#}

# making and writing out a fasta of our final ASV seqs:
asv_fasta <- c(rbind(asv_headers, asv_seqs))
write(asv_fasta, paste0(output, name, "_ASVs.fa"))

# count table:
asv_tab <- t(seqtab.nochim)
row.names(asv_tab) <- sub(">", "", asv_headers)
write.table(asv_tab, paste0(output, name, "_ASVs_counts.tsv"), sep="\t", quote=F, col.names=NA)

# tax table:
# creating table of taxonomy
taxid_df <- as.data.frame(taxid)
rownames(taxid_df) <- gsub("^>", "", asv_headers)
write.table(taxid_df, paste0(output, name, "_ASVs_taxonomy.tsv"), sep = "\t", quote=F, col.names=NA)

### end new block 1

# Write to disk
saveRDS(taxid, paste0(output, name, "_tax_assignation.rds"))

### LJ added
###
### Create a sample info file with year, period, site and specimen name.
###

# Assuming your sample names are stored as row names
sample_names <- rownames(seqtab.nochim)

# Initialize a counter for NA specimens
na_counter <- 1

# Initialize empty vectors to store the extracted information
year <- character(length(sample_names))
period <- character(length(sample_names))
site <- character(length(sample_names))
specimen <- character(length(sample_names))
type <- character(length(sample_names))
plate <- character(length(sample_names))
quant_reading <- character(length(sample_names))

# Loop through each sample name to extract the necessary information
for (i in seq_along(sample_names)) {
  sample <- sample_names[i]
  
  # If the sample name follows the standard pattern
  if (grepl("^GBP", sample)) {
    year[i] <- substr(sample,4, 5)                      # Extract year (characters 4 and 5)
    period[i] <- paste0("p", substr(sample, 6, 7))      # Extract period (characters 6 and 7) and add "p" at the beginnig
    site[i] <- paste0("s", substr(sample, 8, 9))        # Extract site (characters 8 and 9) and add "s" at the beginnig
    specimen[i] <- substr(sample, 10, 12)               # Extract specimen (characters 10 to 12)
    plate[i] <- substr(sample, nchar(sample) - 2, nchar(sample))  # Extract last 3 characters (plate)
    type[i] <- "sample"                                 # Add sample type
  } else {
    # Handle cases like "neg9_16S"
    year[i] <- NA
    period[i] <-"pNA"
    site[i] <- "sNA"
    plate[i] <- substr(sample, nchar(sample) - 2, nchar(sample))  # Extract last 3 characters (plate)
    type[i] <- "negative"
    # Assign NA with a counter (e.g., "NA1", "NA2", etc.)
    specimen[i] <- paste0("NA", na_counter)
    # Increment the counter for NA specimens
    na_counter <- na_counter + 1
  }
  
  # Match the sample name with the track.analysis dataframe and extract the 'raw' value
  match_idx <- which(track.analysis$sample == sample)
  if (length(match_idx) > 0) {
    quant_reading[i] <- track.analysis$raw[match_idx]  # If match found, fill with 'raw' value
  } else {
    quant_reading[i] <- NA  # If no match found, assign NA
  }
}

# Assign colors based on the 'period' (6 colors) and 'site' (16 colors)
period_colors <- viridis(6)  # 6 distinct colors from viridis
site_colors <- inferno(16)   # 16 distinct colors from inferno

# Create new columns to store the colors
color_p <- character(length(sample_names))
color_s <- character(length(sample_names))

# Loop through each sample and assign colors
for (i in seq_along(sample_names)) {
  
  # Assign color for period (based on period p01 to p06)
  if (period[i] == "pNA") {
    color_p[i] <- "red"  # Set color to red if period is pNA
  } else if (!is.na(period[i])) {
    # Remove the "p" and convert to numeric
    period_num <- as.numeric(sub("p", "", period[i]))
    if (!is.na(period_num) && period_num >= 1 && period_num <= 6) {
      color_p[i] <- period_colors[period_num]
    } else {
      color_p[i] <- NA  # For invalid or missing periods
    }
  } else {
    color_p[i] <- NA  # If period is NA, set color_p to NA
  }
  
  # Assign color for site (based on site s01 to s16)
  if (site[i] == "sNA") {
    color_s[i] <- "red"  # Set color to red if site is sNA
  } else if (!is.na(site[i])) {
    # Remove the "s" and convert to numeric
    site_num <- as.numeric(sub("s", "", site[i]))
    if (!is.na(site_num) && site_num >= 1 && site_num <= 16) {
      color_s[i] <- site_colors[site_num]
    } else {
      color_s[i] <- NA  # For invalid or missing sites
    }
  } else {
    color_s[i] <- NA  # If site is NA, set color_s to NA
  }
}

# Create a data frame with the sample names and the extracted information
sample_data <- data.frame(
  sample_name = sample_names,
  year = year,
  period = period,
  site = site,
  specimen = specimen,
  color_p = color_p,   # Colors based on 'period'
  color_s = color_s,   # Colors based on 'site'
  type = type,
  plate = plate,
  quant_reading = quant_reading,
  stringsAsFactors = FALSE
)

# Save to a TSV file
write.table(sample_data, paste0(output, "sample_info.tsv"), sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)

### end new block 2

cat('\n')
cat(paste0('# The obtained taxonomy file can be found in "', paste0(output, name, "_tax_assignation.rds"), '"\n'))
cat('\n# All done!\n\n')
