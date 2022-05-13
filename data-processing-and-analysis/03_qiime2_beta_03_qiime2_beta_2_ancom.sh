#!/bin/bash

#SBATCH --job-name=03_qiime2_beta_2_ancom
#SBATCH -p medium
#SBATCH -N 1
#SBATCH -n 8
#SBATCH --cpus-per-task=4
#SBATCH --mem=40000
#SBATCH --time=5-00:00:00
#SBATCH --mail-user=a.castellanoss@uniandes.edu.co
#SBATCH --mail-type=ALL
#SBATCH -o 03_qiime2_beta_2_ancom.o

# conda init bash
# conda activate qiime2-2021.11
module load qiime2/qiime2-2021.11

## Beta diversity significance
qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/weighted_unifrac_distance_matrix.qza \
  --m-metadata-file manifest_file.tsv \
  --m-metadata-column diet_type \
  --o-visualization diversity-metrics-results/weighted-unifrac-diet_type-significance.qzv \
  --p-pairwise

qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/weighted_unifrac_distance_matrix.qza \
  --m-metadata-file manifest_file.tsv \
  --m-metadata-column fruit_frequency \
  --o-visualization diversity-metrics-results/weighted-unifrac-fruit_frequency-significance.qzv \
  --p-pairwise

qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/weighted_unifrac_distance_matrix.qza \
  --m-metadata-file manifest_file.tsv \
  --m-metadata-column vegetable_frequency \
  --o-visualization diversity-metrics-results/weighted-unifrac-vegetable_frequency-significance.qzv \
  --p-pairwise

qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-results/weighted_unifrac_distance_matrix.qza \
  --m-metadata-file manifest_file.tsv \
  --m-metadata-column whole_grain_frequency \
  --o-visualization diversity-metrics-results/weighted-unifrac-whole_grain_frequency-significance.qzv \
  --p-pairwise

# Differential abundance testing with ANCOM

qiime composition add-pseudocount \
  --i-table filtered-sequences/filtered-table2.qza \
  --o-composition-table comp-filtered-table2.qza

qiime taxa collapse \
  --i-table filtered-sequences/filtered-table2.qza \
  --i-taxonomy taxonomy.qza \
  --p-level 6 \
  --o-collapsed-table filtered-table2-l6.qza

qiime composition add-pseudocount \
  --i-table filtered-table2-l6.qza \
  --o-composition-table comp-filtered-table2-l6.qza

qiime composition ancom \
  --i-table comp-filtered-table2.qza \
  --m-metadata-file sample-metadata.tsv \
  --m-metadata-column data_type \
  --o-visualization ancom-data_type.qzv

qiime composition ancom \
  --i-table comp-filtered-table2-l6.qza \
  --m-metadata-file sample-metadata.tsv \
  --m-metadata-column data_type \
  --o-visualization ancom-data_type-l6.qzv

qiime composition ancom \
  --i-table comp-filtered-table2.qza \
  --m-metadata-file sample-metadata.tsv \
  --m-metadata-column fruit_frequency \
  --o-visualization ancom-fruit_frequency.qzv

qiime composition ancom \
  --i-table comp-filtered-table2-l6.qza \
  --m-metadata-file sample-metadata.tsv \
  --m-metadata-column fruit_frequency \
  --o-visualization ancom-fruit_frequency-l6.qzv

qiime composition ancom \
  --i-table comp-filtered-table2.qza \
  --m-metadata-file sample-metadata.tsv \
  --m-metadata-column vegetable_frequency \
  --o-visualization ancom-vegetable_frequency.qzv

qiime composition ancom \
  --i-table comp-filtered-table2-l6.qza \
  --m-metadata-file sample-metadata.tsv \
  --m-metadata-column vegetable_frequency \
  --o-visualization ancom-vegetable_frequency-l6.qzv

qiime composition ancom \
  --i-table comp-filtered-table2.qza \
  --m-metadata-file sample-metadata.tsv \
  --m-metadata-column whole_grain_frequency \
  --o-visualization ancom-whole_grain_frequency.qzv

qiime composition ancom \
  --i-table comp-filtered-table2-l6.qza \
  --m-metadata-file sample-metadata.tsv \
  --m-metadata-column whole_grain_frequency \
  --o-visualization ancom-whole_grain_frequency-l6.qzv