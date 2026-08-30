#!/usr/bin/env bash
#
# qc_pipeline.sh
# Runs FastQC on raw reads, then (assuming fastp trimming has already
# produced results/fastp_trimmed/) runs FastQC on the trimmed paired
# reads, then MultiQC to aggregate raw FastQC + fastp + post-trim FastQC
# into one report.

set -euo pipefail

# Always run relative to the project root (parent of this scripts/ folder),
# no matter where this script is invoked from.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

SAMPLE="DRR187559"
THREADS=4

RAW_DIR="data/raw"                       # adjust to wherever your raw fastqs live
FASTP_DIR="results/fastp_trimmed"
FASTQC_DIR="results/fastqc_raw"
POSTRIM_QC_DIR="results/fastqc_posttrim"
MULTIQC_DIR="results/multiqc"

mkdir -p "$FASTQC_DIR" "$POSTRIM_QC_DIR" "$MULTIQC_DIR"

R1_RAW="${RAW_DIR}/${SAMPLE}_1.fastq.gz"
R2_RAW="${RAW_DIR}/${SAMPLE}_2.fastq.gz"

R1_PAIRED="${FASTP_DIR}/${SAMPLE}_R1_fastp_paired.fastq.gz"
R2_PAIRED="${FASTP_DIR}/${SAMPLE}_R2_fastp_paired.fastq.gz"

# --- Pretrim FastQC ---
echo "[INFO] Running FastQC on raw reads"

if [[ ! -f "$R1_RAW" || ! -f "$R2_RAW" ]]; then
    echo "[ERROR] Raw reads not found at ${R1_RAW} / ${R2_RAW}. Check RAW_DIR/filenames."
    exit 1
fi

fastqc "$R1_RAW" "$R2_RAW" \
    -o "$FASTQC_DIR" \
    --threads "$THREADS"

# --- Post-trim FastQC ---
echo "[INFO] Running FastQC on fastp-trimmed paired reads"

if [[ ! -f "$R1_PAIRED" || ! -f "$R2_PAIRED" ]]; then
    echo "[ERROR] Trimmed reads not found at ${R1_PAIRED} / ${R2_PAIRED}. Run fastp trimming first."
    exit 1
fi

fastqc "$R1_PAIRED" "$R2_PAIRED" \
    -o "$POSTRIM_QC_DIR" \
    --threads "$THREADS"

# --- MultiQC ---
echo "[INFO] Running MultiQC to aggregate raw FastQC + fastp + post-trim FastQC"
multiqc \
    "$FASTQC_DIR" \
    "$FASTP_DIR" \
    "$POSTRIM_QC_DIR" \
    -o "$MULTIQC_DIR" \
    -n "${SAMPLE}_multiqc_report"

echo "[DONE] Pretrim QC:  ${FASTQC_DIR}"
echo "[DONE] Post-trim QC: ${POSTRIM_QC_DIR}"
echo "[DONE] MultiQC report: ${MULTIQC_DIR}/${SAMPLE}_multiqc_report.html"