#!/usr/bin/env bash
#
# bakta_annotation.sh
# Runs Bakta gene prediction/annotation on the MEGAHIT contigs.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

SAMPLE="DRR187559"
THREADS=2

CONTIGS="results/megahit_assembly/${SAMPLE}/${SAMPLE}.contigs.fa"
BAKTA_DB="/home/divya/bakta_db/db-light"
OUT_DIR="results/bakta/${SAMPLE}"

GENUS="Staphylococcus"

mkdir -p logs "$OUT_DIR"

echo "[INFO] Contigs: $CONTIGS"

if [[ ! -f "$CONTIGS" ]]; then
    echo "[ERROR] Contigs file not found at ${CONTIGS}. Run megahit_assembly.sh first."
    exit 1
fi

if [[ ! -d "$BAKTA_DB" ]]; then
    echo "[ERROR] Bakta DB not found at ${BAKTA_DB}."
    exit 1
fi

echo "[INFO] Running Bakta (streams to both screen and logs/bakta_${SAMPLE}.log)"
bakta \
    --db "$BAKTA_DB" \
    --output "$OUT_DIR" \
    --prefix "$SAMPLE" \
    --genus "$GENUS" \
    --threads "$THREADS" \
    --verbose \
    --force \
    "$CONTIGS" \
    2>&1 | tee "logs/bakta_${SAMPLE}.log"

echo "[DONE] Bakta output: ${OUT_DIR}"