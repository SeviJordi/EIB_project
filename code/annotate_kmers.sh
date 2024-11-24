#!/bin/sh
#SBATCH --job-name=annotate_kmers
#SBATCH --output=ann_km_%j.out
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --time=04:40:00
#SBATCH --mem=32G
#SBATCH --qos=short
# Script for annotating the significant k-mers in a reference genome
# Activate a conda environment with pyseer and prokka installed if needed
# help function
helpFunction()
{
   echo ""
   echo "Usage: $0 -i input -o output -r reference"
   echo -e "\t-i input file with significant k-mers"
   echo -e "\t-o output_dir"
   echo -e "\t-r reference genome"
   exit 1 # Exit script after printing help
}

while getopts "i:o:r:" opt
do
   case "$opt" in
      i ) input="$OPTARG" ;;
      o ) output="$OPTARG" ;;
      r ) reference="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$input" ] || [ -z "$output" ] || [ -z "$reference" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

# Check if the input file exists
if [ ! -f $input ]
then
   echo "Input file not found!";
   helpFunction
fi

# Annotate the reference genome
prokka --cpus $SLURM_CPUS_PER_TASK --outdir $output/prokka --centre X --compliant --prefix reference $reference

# Annotate the significant k-mers
## Create references txt
echo -e "$output/prokka/reference.fna\t$output/prokka/reference.gff\tref" > $output/references.txt

## Annotate the significant k-mers
annotate_hits_pyseer $input $output/references.txt $output/annotated_kmers.txt

## Summarize the annotations
python code/summarize_annotations.py --nearby $output/annotated_kmers.txt > $output/summary.txt

exit 0
