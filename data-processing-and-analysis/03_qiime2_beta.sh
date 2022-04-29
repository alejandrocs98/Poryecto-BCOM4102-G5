#!/bin/bash

#SBATCH --job-name=03_qiime2_beta
#SBATCH -p medium
#SBATCH -N 1
#SBATCH -n 8
#SBATCH --cpus-per-task=4
#SBATCH --mem=40000
#SBATCH --time=5-00:00:00
#SBATCH --mail-user=a.castellanoss@uniandes.edu.co
#SBATCH --mail-type=ALL
#SBATCH -o 03_qiime2_beta.o

# conda init bash
# conda activate qiime2-2022.2
module load qiime2/qiime2-2022.2

## Beta diversity significance
qiime diversity beta-group-significance \
  --i-distance-matrix diversity-metrics-results/weighted_unifrac_distance_matrix.qza \
  --m-metadata-file manifest_file.tsv \
  --m-metadata-column diet_type \
  --o-visualization diversity-metrics-results/weighted-unifrac-diet_type-significance.qzv \
  --p-pairwise