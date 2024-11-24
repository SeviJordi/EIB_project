#!/bin/sh
#SBATCH --job-name=pyseer
#SBATCH --output=pyseer_%j.out
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --time=02-00:40:00
#SBATCH --mem=64G
#SBATCH --qos=medium

# Activate conda environment with pyseer if needed
# help function

helpFunction()
{
   echo ""
   echo "Usage: $0 -p <pheno> -t <tree> -o <output_dir> -k <kmer_file>"
    echo -e "\t-p Phenotype file"
    echo -e "\t-t Tree file"
    echo -e "\t-o Output directory"
    echo -e "\t-k Kmer file"
    exit 1 # Exit script after printing help

}

while getopts "p:t:o:k:" opt
do
   case "$opt" in
      p ) pheno="$OPTARG" ;;
      t ) tree="$OPTARG" ;;
      o ) out_dir="$OPTARG" ;;
      k ) kmer="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$pheno" ] || [ -z "$tree" ] || [ -z "$out_dir" ] || [ -z "$kmer" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

# create output directory
mkdir -p $out_dir

# Get similarity matrix from tree
python code/phylogeny_distance.py --lmm $tree > $out_dir/similarity_matrix.txt

# Run pyseer
pyseer --lmm \
    --phenotypes $pheno \
    --kmers $kmer \
    --similarity $out_dir/similarity_matrix.txt \
    --output-patterns $out_dir/kmer_patterns.txt \
    --cpu $SLURM_CPUS_PER_TASK > $out_dir/meropenem_kmers.txt

# Get number of patterns and threshold
python code/count_patterns \
    --alpha 0.01 \
    $out_dir/kmer_patterns.txt > $out_dir/pattern_counts.txt

# Get significant kmers
threshold=$(cat $out_dir/pattern_counts.txt | grep "Threshold" | cut -f 2)

cat <(head -1 $out_dir/meropenem_kmers.txt) \
    <(awk -v threshold=$threshold '$4<threshold {print $0}' $out_dir/meropenem_kmers.txt) > $out_dir/significant_kmers.txt

