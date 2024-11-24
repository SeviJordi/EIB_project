#!/bin/sh
#SBATCH --job-name=fsm
#SBATCH --output=fsm_%j.out
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --time=02-00:40:00
#SBATCH --mem=16G
#SBATCH --qos=medium

# Activate conda environment with fsm-lite installed if needed
# help function
usage() {
    echo "Usage: $0 -i <input_dir> -o <output_dir> "
    echo "  -i <input_dir>      : input dir with the assembly files (renamed)"
    echo "  -o <output_dir>     : output dir to save the results"
    exit 1
}

# parse input arguments
while getopts "i:o:" opt; do
    case $opt in
        i) input_dir="$OPTARG"
        ;;
        o) output_dir="$OPTARG"
        ;;
        \?) echo "Invalid option -$OPTARG" >&2
            usage
        ;;
    esac
done

# check if input_dir and output_dir are provided
if [ -z "$input_dir" ] || [ -z "$output_dir" ]; then
    echo "input_dir and output_dir are required"
    usage
fi

# check if input_dir exists
if [ ! -d "$input_dir" ]; then
    echo "input_dir does not exist"
    usage
fi

# Create input list for fsm-lite
for f in $input_dir/*; do 
    id=$(basename "$f" .fasta); echo $id $f
done > $output_dir/input.list

# Run fsm-lite
fsm-lite -l $output_dir/input.list -s 2 -S 1200 -v -t fsm_kmers | gzip -c - > $output_dir/fsm_kmers.txt.gz

exit 0

