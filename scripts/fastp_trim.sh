#!/usr/bin/env bash
#
# fastp_trim.sh
# Trims raw reads with fastp, writing into results/fastp_trimmed/.

set -euo pipefail

# Always run relative to the project root (parent of this scripts/ folder),
# no matter where this script is invoked from.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

SAMPLE="DRR187559"
THREADS=4

IN_DIR="data/fastq"
OUT_DIR="results/fastp_trimmed"
mkdir -p "$OUT_DIR"

fastp \
  -i "${IN_DIR}/${SAMPLE}_1.fastq.gz" \
  -I "${IN_DIR}/${SAMPLE}_2.fastq.gz" \
  -o "${OUT_DIR}/${SAMPLE}_R1_fastp_paired.fastq.gz" \
  -O "${OUT_DIR}/${SAMPLE}_R2_fastp_paired.fastq.gz" \
  --detect_adapter_for_pe \
  --html "${OUT_DIR}/${SAMPLE}_fastp_report.html" \
  --json "${OUT_DIR}/${SAMPLE}_fastp_report.json" \
  --thread "$THREADS"

echo "[DONE] fastp output in ${OUT_DIR}"
