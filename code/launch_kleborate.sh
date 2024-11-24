#!/bin/sh
#SBATCH --job-name=kleborate
#SBATCH --output=kleborate_%j.out
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --time=02-00:40:00
#SBATCH --mem=16G
#SBATCH --qos=medium

# Activate a conda environment with kleborte installed if needed

# help function
helpFunction()
{
   echo ""
   echo "Usage: $0 -i input_dir -o output_file"
   echo -e "\t-i directory with spades assemblies"
   echo -e "\t-o output_file"
   exit 1 # Exit script after printing help
}

# Get the options
while getopts "i:o:" opt
do
   case "$opt" in
      i ) input_dir="$OPTARG" ;;
      o ) output_file="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# rename contigs
mkdir -p $input_dir/renamed
for sample in $(ls $input_dir); do
    cp $input_dir/$sample/contigs.fasta $input_dir/renamed/$sample.fasta
done

# run kleborate
kleborate --all -a $input_dir/renamed/* -o $output_file

exit 0