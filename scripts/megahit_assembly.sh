#!/usr/bin/env bash
#
# megahit_assembly.sh
# Runs MEGAHIT de novo assembly on the fastp-trimmed reads.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

SAMPLE="DRR187559"
THREADS=4

FASTP_DIR="results/fastp_trimmed"
MEGAHIT_DIR="results/megahit_assembly/${SAMPLE}"

R1="${FASTP_DIR}/${SAMPLE}_R1_fastp_paired.fastq.gz"
R2="${FASTP_DIR}/${SAMPLE}_R2_fastp_paired.fastq.gz"

mkdir -p logs

echo "[INFO] R1: $R1"
echo "[INFO] R2: $R2"
echo "[INFO] Output: $MEGAHIT_DIR"

if [[ ! -f "$R1" || ! -f "$R2" ]]; then
    echo "[ERROR] Input read file(s) not found. Check paths above."
    exit 1
fi

# megahit creates MEGAHIT_DIR itself and refuses to run if it already
# exists (add --continue to the command below to resume an interrupted run).
if [[ -d "$MEGAHIT_DIR" ]]; then
    echo "[WARN] ${MEGAHIT_DIR} already exists — megahit will refuse to run."
    echo "       Delete it first, or edit this script to add --continue, then re-run."
    exit 1
fi

echo "[INFO] Running MEGAHIT (this streams to both screen and logs/megahit_${SAMPLE}.log)"
megahit \
    -1 "$R1" \
    -2 "$R2" \
    -o "$MEGAHIT_DIR" \
    --out-prefix "$SAMPLE" \
    -t "$THREADS" \
    2>&1 | tee "logs/megahit_${SAMPLE}.log"

CONTIGS="${MEGAHIT_DIR}/${SAMPLE}.contigs.fa"
if [[ ! -f "$CONTIGS" ]]; then
    echo "[ERROR] Contigs file not found at ${CONTIGS} — check logs/megahit_${SAMPLE}.log"
    exit 1
fi

echo "[DONE] MEGAHIT contigs: ${CONTIGS}"
