#!/bin/sh
#SBATCH --job-name=kraken_db
#SBATCH --output=kraken_db_%j.out
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --time=1-02:40:00
#SBATCH --mem=60G
#SBATCH --qos=medium

# Activate module
module load kraken2

# Create directory for kraken database
db_dir=kraken_db

# Download and build kraken database
kraken2-build --download-taxonomy --db $db_dir
kraken2-build --download-library bacteria --db $db_dir
kraken2-build --build --db $db_dir

exit 0
