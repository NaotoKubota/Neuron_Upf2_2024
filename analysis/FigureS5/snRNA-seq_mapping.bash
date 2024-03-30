#!/bin/bash -l

########################################################################################

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=100G
#SBATCH --mail-type=ALL
#SBATCH --job-name="Aug23_STARsolo"
#SBATCH -p batch

# Print current date
date

########################################################################################


# Load module
module load singularity


# Singularity image
STAR_SINGULARITY=/bigdata/zhenglab/naotok/singularity/star_2.7.11a--h0033a41_0.sif


# Set path
DATAPATH=/rhome/naotok/bigdata/Upf2_paper/Aug23/STARsolo


for x in Ctrl KO
do

	# FASTQ list
	fastq_R2=$(ls /rhome/naotok/bigdata/Upf2_paper/Aug23/01.RawData/${x}_*/*R2*.fastq.gz | xargs -n100 | sed -e 's/ /,/g')
	fastq_R1=$(ls /rhome/naotok/bigdata/Upf2_paper/Aug23/01.RawData/${x}_*/*R1*.fastq.gz | xargs -n100 | sed -e 's/ /,/g')

	# Run STARsolo
	mkdir -p ${DATAPATH}/${x} && \
	cd ${DATAPATH}/${x} && \
	singularity exec ${STAR_SINGULARITY} \
	STAR \
	--runThreadN 32 \
	--soloType CB_UMI_Simple \
	--genomeDir /bigdata/zhenglab/naotok/STAR/index_mm10_STARsolo \
	--readFilesIn \
	${fastq_R2} \
	${fastq_R1} \
	--readFilesCommand zcat \
	--soloCBwhitelist /bigdata/zhenglab/naotok/10x/annotations/cellranger_ref/3M-february-2018.txt \
	--soloUMIlen 12 \
	--soloCellFilter EmptyDrops_CR \
	--soloFeatures Gene GeneFull SJ Velocyto \
	--clipAdapterType CellRanger4 \
	--outFilterScoreMin 30 \
	--soloCBmatchWLtype 1MM_multi_Nbase_pseudocounts \
	--soloUMIfiltering MultiGeneUMI_CR \
	--soloUMIdedup 1MM_CR \
	--outSAMattributes NH HI nM AS CR UR CB UB GX GN sS sQ sM \
	--outSAMtype BAM SortedByCoordinate \
	--soloBarcodeReadLength 150

done


# Print end date
date


# Print name of node
hostname
