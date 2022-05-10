#!/bin/bash

#SBATCH --job-name=02_qiime2_filter_2_alpha
#SBATCH -p medium
#SBATCH -N 1
#SBATCH -n 8
#SBATCH --cpus-per-task=4
#SBATCH --mem=40000
#SBATCH --time=5-00:00:00
#SBATCH --mail-user=a.castellanoss@uniandes.edu.co
#SBATCH --mail-type=ALL
#SBATCH -o 02_qiime2_filter_2_alpha.o

# conda init bash
# conda activate qiime2-2022.2
module load qiime2/qiime2-2022.2

# Filter feature table 
mkdir filtered-sequences 
qiime feature-table filter-samples \
  --i-table table.qza \
  --p-min-frequency 10 \
  --o-filtered-table filtered-sequences/filtered-table.qza

# Filter features with low abundance
qiime feature-table filter-features \
  --i-table filtered-sequences/filtered-table.qza \
  --p-min-frequency 10 \
  --o-filtered-table filtered-sequences/feature-frequency-filtered-table.qza

# Assign taxonomy
qiime feature-classifier classify-sklearn \
  --i-classifier gg-13-8-99-515-806-nb-classifier.qza \
  --i-reads rep-seqs.qza \
  --o-classification taxonomy.qza

# Visualize taxonomy
qiime metadata tabulate \
  --m-input-file taxonomy.qza \
  --o-visualization taxonomy.qzv

# Remove unwanted taxa from tables and sequences
qiime taxa filter-table \
  --i-table filtered-sequences/feature-frequency-filtered-table.qza \
  --i-taxonomy taxonomy.qza \
  --p-include p__ \
  --p-exclude mitochondria,chloroplast \
  --o-filtered-table filtered-sequences/table-with-phyla-no-mitochondria-chloroplast.qza
 
qiime taxa filter-table \
  --i-table filtered-sequences/table-with-phyla-no-mitochondria-chloroplast.qza \
  --i-taxonomy taxonomy.qza \
  --p-exclude "k__Archaea" \
  --o-filtered-table filtered-sequences/table-with-phyla-no-mitochondria-chloroplasts-archaea.qza
 
qiime taxa filter-table \
  --i-table filtered-sequences/table-with-phyla-no-mitochondria-chloroplasts-archaea.qza \
  --i-taxonomy taxonomy.qza \
 --p-exclude "k__Eukaryota" \
  --o-filtered-table filtered-sequences/table-with-phyla-no-mitochondria-chloroplasts-archaea-eukaryota.qza
 
qiime taxa filter-seqs \
  --i-sequences rep-seqs.qza \
  --i-taxonomy taxonomy.qza \
  --p-include p__ \
  --p-exclude mitochondria,chloroplast \
  --o-filtered-sequences filtered-sequences/rep-seqs-with-phyla-no-mitochondria-chloroplast.qza
 
qiime taxa filter-seqs \
  --i-sequences filtered-sequences/rep-seqs-with-phyla-no-mitochondria-chloroplast.qza \
  --i-taxonomy taxonomy.qza \
  --p-exclude "k__Archaea" \
  --o-filtered-sequences filtered-sequences/rep-seqs-with-phyla-no-mitochondria-chloroplasts-archaea.qza
 
qiime taxa filter-seqs \
  --i-sequences filtered-sequences/rep-seqs-with-phyla-no-mitochondria-chloroplasts-archaea.qza \
  --i-taxonomy taxonomy.qza \
  --p-exclude "k__Eukaryota" \
  --o-filtered-sequences filtered-sequences/rep-seqs-with-phyla-no-mitochondria-chloroplasts-archaea-eukaryota.qza
 
 
mv filtered-sequences/table-with-phyla-no-mitochondria-chloroplasts-archaea-eukaryota.qza filtered-sequences/filtered-table2.qza
mv filtered-sequences/rep-seqs-with-phyla-no-mitochondria-chloroplasts-archaea-eukaryota.qza filtered-sequences/filtered-rep-seqs.qza

# Visualize taxonomic classifications
qiime taxa barplot \
  --i-table filtered-sequences/filtered-table2.qza \
  --i-taxonomy taxonomy.qza \
  --m-metadata-file manifest_file.tsv \
  --o-visualization taxa-bar-plots2.qzv

  qiime feature-table summarize \
  --i-table filtered-sequences/filtered-table2.qza \
  --o-visualization filtered-sequences/filtered-table2.qzv \
  --m-sample-metadata-file manifest_file.tsv

# Phylogenetic Tree for phylogenetic diversity analysis
qiime phylogeny align-to-tree-mafft-fasttree \
  --i-sequences filtered-sequences/filtered-rep-seqs.qza \
  --o-alignment aligned-rep-seqs.qza \
  --o-masked-alignment masked-aligned-rep-seqs.qza \
  --o-tree unrooted-tree.qza \
  --o-rooted-tree rooted-tree.qza

# Rarefaction analysis
qiime diversity alpha-rarefaction \
  --i-table  filtered-sequences/filtered-table2.qza \
  --o-visualization alpha-rarefaction.qzv \
  --p-max-depth 10000

# Core diversity metrics results
qiime diversity core-metrics-phylogenetic \
  --i-phylogeny rooted-tree.qza \
  --i-table filtered-sequences/filtered-table2.qza \
  --p-sampling-depth 10000 \
  --m-metadata-file manifest_file.tsv \
  --output-dir core-metrics-results

# Alpha diveristy significance
qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-results/faith_pd_vector.qza \
  --m-metadata-file manifest_file.tsv \
  --o-visualization diversity-metrics-results/faith-pd-group-significance.qzv

qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-results/evenness_vector.qza \
  --m-metadata-file manifest_file.tsv \
  --o-visualization diversity-metrics-results/evenness-group-significance.qzv
 
qiime diversity alpha-group-significance \
  --i-alpha-diversity diversity-metrics-results/shannon_vector.qza \
  --m-metadata-file manifest_file.tsv \
  --o-visualization diversity-metrics-results/shannon-group-significance.qzv