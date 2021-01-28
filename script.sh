#!/bin/bash
echo "Welcome"

FILE_PATH="data/trimmed_fastq_small/"

find "$FILE_PATH" -name "*.fasta" | 
while IFS= read -r my_file
do
	filename=$(basename "$my_file")
	basename=$(basename "$my_file" .fasta)
 	echo $basename

	mkdir -p results/sam results/bam results/bcf results/vcf
	bwa mem data/ref_genome/sequences.fasta data/trimmed_fastq_small/$filename > results/sam/$basename.aligned.sam
	samtools view -S -b results/sam/$basename.aligned.sam > results/bam/$basename.aligned.bam
	samtools sort -o results/bam/$basename.sorted.bam results/bam/$basename.aligned.bam 

	bcftools mpileup -O b -o results/bcf/$basename.bcf -f data/ref_genome/sequences.fasta results/bam/$basename.sorted.bam 
	bcftools call --ploidy 1 -m -v -o results/bcf/$basename.vcf results/bcf/$basename.bcf
	vcfutils.pl varFilter results/bcf/$basename.vcf  > results/vcf/$basename.vcf
	bgzip -c results/bcf/$basename.vcf > results/bcf/$basename.vcf.gz
	tabix -p vcf results/bcf/$basename.vcf.gz

done

mkdir "Variant_Results"
cp -r results/bcf/*.vcf Variant_Results/

rem mkdir "Variant_Results_of_COVID_gz"
rem cp -r results/bcf/*.vcf.gz Variant_Results_of_COVID_gz/
rem cp -r results/bcf/*.vcf.gz.tbi Variant_Results_of_COVID_gz/


bcftools merge results/bcf/*.vcf.gz -Oz -o Merge_Final_Variants.vcf.gz
gunzip Merge_Final_Variants.vcf.gz 



echo "*================================================================*"
echo "*				        			       *"
echo "*			 Successfuly Done!     			       *"				
echo "*								       *"
echo "*================================================================*"


