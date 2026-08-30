#!/usr/bin/env bash
#
# make_dirs.sh
# Creates the full folder structure for the pipeline, matching the
# naming convention already in use (data/fastq, results/fastqc_raw, ...).
# Safe to re-run — mkdir -p won't touch folders/files that already exist.

set -euo pipefail

mkdir -p data/fastq

mkdir -p results/fastqc_raw
mkdir -p results/fastp_trimmed
mkdir -p results/trimmomatic_trimmed
mkdir -p results/fastqc_posttrim
mkdir -p results/multiqc
mkdir -p results/megahit_assembly
mkdir -p results/kraken_bracken
mkdir -p results/busco
mkdir -p results/quast
mkdir -p results/bakta
mkdir -p results/plasmidfinder
mkdir -p results/amrfinder
mkdir -p results/eggnog_mapper

mkdir -p scripts
mkdir -p logs
mkdir -p envs

echo "[DONE] Folder structure ready."
find . -maxdepth 3 -type d -not -path './.git*' | sort
