#!/bin/sh
#SBATCH --job-name=pangenome
#SBATCH --output=pangenome_%j.out
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --time=04-00:30:00
#SBATCH --mem=64G
#SBATCH --qos=medium

# Activate a conda environment with panaroo and iqtree installed if necessary

# log function
log() {
    echo "$(date) $@"
}

# help function
usage(){
cat << EOF
usage: $0 options
This script will run panaroo on a set of genomes

OPTIONS:
   -i      Input directory containing all annotations
   -p      Oprefix for output files

EOF
}

# parse the options
while getopts "i:p:" OPTION
do
    case $OPTION in
        i)
            INDIR=$OPTARG
            ;;
        p)
            PREFIX=$OPTARG
            ;;
        ?)
            usage
            exit
            ;;
    esac
done

# check if the input directory exists
if [ ! -d $INDIR ]; then
    echo "Input directory does not exist"
    exit 1
fi

# Run panaroo
panaroo -i $INDIR/**/*.gff \
       -o panaroo \
       -t $SLURM_CPUS_PER_TASK \
       --alignment core \
       --aligner mafft \
       --core_threshold 0.9 \
       --clean-mode sensitive \
       --merge_paralogs

log "Finished running panaroo"

# Run iqtree
mkdir -p IQTREE
## Get SNPs from core alignment
snp-sites -c panaroo/core_gene_alignment_filtered.aln \
          -o phylo/core_phylo.snps.fasta

## Get constant sites
fconstvar=$(snp-sites -C panaroo/core_gene_alignment_filtered.aln)

## Run iqtree
iqtree2 -s phylo/core_phylo.snps.fasta \
       --prefix IQTREE/$PREFIX \
       -T $SLURM_CPUS_PER_TASK \
       -m "GTR+F+I+G4" \
       -bb 1000 \
       -fconst $fconstvar

log "Finished running iqtree"

exit 0
