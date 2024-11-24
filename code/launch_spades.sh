#!/bin/sh
#SBATCH --job-name=arrayJob
#SBATCH --output=spades_%A_%a.out
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --time=00:40:00
#SBATCH --mem=16G
#SBATCH --qos=medium

# Activate the module 
module load spades

# Set help function
helpFunction()
{
   echo ""
   echo "Usage: $0 -i inputDir -o outputDir"
   echo -e "\t-i Directory containing the input files (fastq.gz)"
   echo -e "\t-o Directory where the output files will be stored"
   echo -e "\t-n Names of the samples that passed the kraken2 filter"
   exit 1 # Exit script after printing help
}

while getopts "i:o:n:" opt
do
   case "$opt" in
      i ) inputDir="$OPTARG" ;;
      o ) outputDir="$OPTARG" ;;
      n ) names="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Check params
if [ -z "$inputDir" ] || [ -z "$outputDir" ] || [ -z "$names" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

if [ ! -d "$inputDir" ] || [ ! -d "$outputDir" ]
then
    echo "Some or all of the directories do not exist";
    helpFunction
fi

# Create the output directory
mkdir -p $outputDir

# Set up arrat job
inputFiles=($(cat $names))
sample=${inputFiles[$SLURM_ARRAY_TASK_ID]}

# Run spades
spades.py --threads $SLURM_CPUS_PER_TASK \
    --memory $SLURM_MEM_PER_NODE \
    -o $outputDir/$sample \
    -k 41 49 57 65 77 85 93 \
    --cov-cutoff auto \
    -1 $inputDir/$sample\_1.fastq.gz -2 $inputDir/$sample\_2.fastq.gz

exit 0
