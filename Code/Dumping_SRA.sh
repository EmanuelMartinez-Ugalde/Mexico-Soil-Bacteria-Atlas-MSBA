
#!/bin/bash
#This scritp allows the download of fastq files using a list of SRA accession numbers
#Emanuel Martinez-Ugalde
#18-06-24

#Usage
if [ $# -eq 0 ]; then
    echo "usage: $0 <File with sra accession>"
    exit 1
fi

#Create a first variable for the input file
accession_file=$1

#Error message if prefetch or fastq-dump are missing
if ! command -v prefetch &> /dev/null || ! command -v fastq-dump &> /dev/null; then
    echo "Error: verify if prefetch or fastq-dump are installed in your machine."
    exit 1
fi

#Create a dir to store dumped files
fastq_dir="fastq_files"
mkdir -p "$fastq_dir"

#Loop over each sra id in the input file
while IFS= read -r accession || [[ -n "$accession" ]]; do
    #Create a temp dir for sra files
    tmp_dir=$(mktemp -d -t sra-XXXXXXXXXX)
    
    #Prefetch sra files into temp dir
    prefetch -O "$tmp_dir" "$accession"
    
    #Verify if the prefetch was successful
    if [ $? -eq 0 ]; then
        echo "sra files for $accession have been downloaded"
    else
        echo "err: download failed for $accession."
        rm -rf "$tmp_dir"
        continue
    fi
    
    #Dump fastq files
    fastq-dump --outdir "$fastq_dir" --skip-technical -I -W  --gzip --split-files "$tmp_dir/$accession"
    
    #Verify if dumping was successful
    if [ $? -eq 0 ]; then
        echo "fastq files for $accession have been dumped to $fastq_dir"
    else
        echo "error: dumping failed for $accession."
    fi
    
    #Delete temp dir 
    rm -rf "$tmp_dir"
done < "$accession_file"
