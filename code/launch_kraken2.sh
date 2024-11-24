#!/bin/sh
#SBATCH --job-name=arrayJob
#SBATCH --output=kraken2_%A_%a.out
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --time=00:40:00
#SBATCH --mem=60G
#SBATCH --qos=medium

# Define usage message
if [ $# -lt 4 ]; then
  echo "Usage: $0 <input_dir> <output_dir> <names> <db_dir>"
  echo "  <input_dir>: input directory containing fastq.gz files"
  echo "  <output_dir>: output directory"
  echo "  <names>: file with sample names"
  echo "  <db_dir>: directory with kraken database"
  exit 1
fi

# check args
input_dir=$1
output_dir=$2
names=$3
db_dir=$4

if [ ! -d $input_dir ]; then
  echo "Error: input directory $input_dir does not exist"
  exit 1
fi

if [ ! -d $output_dir ]; then
  echo "Error: output directory $output_dir does not exist"
  exit 1
fi

if [ ! -f $names ]; then
  echo "Error: file with sample names $names does not exist"
  exit 1
fi

if [ ! -d $db_dir ]; then
  echo "Error: kraken database directory $db_dir does not exist"
  exit 1
fi

# Activate module
module load kraken2


# Set up array job
NAMES=($(cat $names))
sample=${NAMES[$SLURM_ARRAY_TASK_ID]}

# Run kraken2
kraken2 --db $db_dir \
    --threads $SLURM_CPUS_PER_TASK \
    --gzip-compressed \
    --output $output_dir/$sample.kraken2.report \
    --report $output_dir/$sample.kraken2.report.txt \
    --report-zero-counts --paired $input_dir/$sample*.gz

exit 0