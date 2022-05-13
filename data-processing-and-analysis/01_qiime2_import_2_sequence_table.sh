#!/bin/bash

#SBATCH --job-name=01_qiime2_import_2_sequence_table
#SBATCH -p medium
#SBATCH -N 1
#SBATCH -n 8
#SBATCH --cpus-per-task=4
#SBATCH --mem=40000
#SBATCH --time=5-00:00:00
#SBATCH --mail-user=a.castellanoss@uniandes.edu.co
#SBATCH --mail-type=ALL
#SBATCH -o 01_qiime2_import_2_sequence_table.o

# conda init bash
# conda activate qiime2-2021.11
module load qiime2/qiime2-2021.11

cp ../data-acquisition/manifest_file.tsv .

# Import data and demultiplex sequences
qiime tools import \
  --type 'SampleData[SequencesWithQuality]' \
  --input-path manifest_file.tsv \
  --output-path single-end-demux.qza \
  --input-format SingleEndFastqManifestPhred33V2

# Visualize quality
qiime demux summarize \
  --i-data single-end-demux.qza \
  --o-visualization single-end-demux.qzv

# Denoise, sequence quality control and feature table (ASVs)
qiime dada2 denoise-single \
  --i-demultiplexed-seqs single-end-demux.qza \
  --p-trim-left 11\
  --p-trunc-len 124 \
  --o-table table.qza \
  --o-representative-sequences rep-seqs.qza \
  --o-denoising-stats denoising-stats.qza

# Visualize denoising stats
qiime metadata tabulate \
  --m-input-file denoising-stats.qza \
  --o-visualization denoising-stats.qzv

# Generate ASV frequency summary
qiime feature-table summarize \
  --i-table table.qza \
  --o-visualization table.qzv \
  --m-sample-metadata-file manifest_file.tsv

# Generate Sequence table visualization
qiime feature-table tabulate-seqs \
  --i-data rep-seqs.qza \
  --o-visualization rep-seqs.qzv