#!/bin/bash
#This script creates a manifest csv file to import fastq files into Qiime2
#Emanuel Martinez-Ugalde
#18-06-24

#Usage
print_usage() {
    echo "Usage: $0 <input_directory> <output_manifest>"
    echo "This script create a manifest file for forward reads"
}

#Review if all arguments were provided
if [ "$#" -ne 2 ]; then
    print_usage
    exit 1
fi

#Path to directory with fastq files
in_dir="$1"

#Path for out file
out_manifest="$2"

#Create the manifest header
echo -e "sample-id\tabsolute-filepath" > "$out_manifest"

#Recover the absolute path
absolute_in_dir=$(realpath "$in_dir")

#For cycle to loop in the fastq dir
#Edit "/*1.fastq.gz" acording to the formating of your fastq names

for file in "$in_dir"/*1.fastq.gz; do
    #Get sample id
    sample_id=$(basename "$file" | cut -d '_' -f 1)

    #Write path in out_manifest file for both f reads
    echo -e "${sample_id}\t$absolute_in_dir/$(basename "$file")" >> "$out_manifest"
done

echo "Done: $out_manifest"
