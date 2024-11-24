#!/bin/sh
#SBATCH --job-name=prokka
#SBATCH --output=prokka_%A_%a.out
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --time=00:30:00
#SBATCH --mem=16G
#SBATCH --qos=short

# Activate a conda environment with prokka installed if needed

# help function
helpFunction()
{
   echo ""
   echo "Usage: $0 -i input_dir -o output_file"
   echo -e "\t-i directory with spades renamed assemblies"
   echo -e "\t-o output_dir"
   exit 1 # Exit script after printing help
}

# Get the options
while getopts "i:o:" opt
do
   case "$opt" in
      i ) input_dir="$OPTARG" ;;
      o ) output_dir="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Check if input_dir or output_dir were passed
if [ -z "$input_dir" ] || [ -z "$output_dir" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

# Check if input_dir exists
if [ ! -d "$input_dir" ]
then
   echo "$input_dir does not exist";
   helpFunction
fi

# Set up array job
INPUTFILES=($input_dir/*)
input_file=${INPUTFILES[$SLURM_ARRAY_TASK_ID]}

# Run prokka
id=$(basename $input_file .fasta)
prokka --cpus 16 --outdir $output_dir/$id --prefix $id $input_file

exit 0
