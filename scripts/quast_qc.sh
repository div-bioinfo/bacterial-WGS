#!/usr/bin/env bash
#
# quast_qc.sh
# Runs QUAST assembly-quality assessment on the MEGAHIT contigs (no
# reference genome).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

SAMPLE="DRR187559"
THREADS=4

CONTIGS="results/megahit_assembly/${SAMPLE}/${SAMPLE}.contigs.fa"
QUAST_DIR="results/quast/${SAMPLE}"

mkdir -p logs "$QUAST_DIR"

echo "[INFO] Contigs: $CONTIGS"

if [[ ! -f "$CONTIGS" ]]; then
    echo "[ERROR] Contigs file not found at ${CONTIGS}. Run megahit_assembly.sh first."
    exit 1
fi

echo "[INFO] Running QUAST (streams to both screen and logs/quast_${SAMPLE}.log)"
quast.py "$CONTIGS" \
    -o "$QUAST_DIR" \
    -t "$THREADS" \
    2>&1 | tee "logs/quast_${SAMPLE}.log"

echo "[DONE] QUAST report: ${QUAST_DIR}/report.html"
