#!/usr/bin/env bash
#
# amrfinder_qc.sh
# Screens the assembly for AMR, virulence, and stress genes.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

SAMPLE="DRR187559"
THREADS=2

CONTIGS="results/megahit_assembly/${SAMPLE}/${SAMPLE}.contigs.fa"
OUT_DIR="results/amrfinder/${SAMPLE}"

# Confirmed via Kraken2/Bracken: Staphylococcus aureus.
# --organism enables organism-specific point-mutation detection
# and better hierarchical gene naming/curation.
ORGANISM="Staphylococcus_aureus"

mkdir -p logs "$OUT_DIR"

echo "[INFO] Contigs: $CONTIGS"

if [[ ! -f "$CONTIGS" ]]; then
    echo "[ERROR] Contigs file not found at ${CONTIGS}. Run megahit_assembly.sh first."
    exit 1
fi

echo "[INFO] Running AMRFinderPlus (streams to both screen and logs/amrfinder_${SAMPLE}.log)"
amrfinder \
    -n "$CONTIGS" \
    --organism "$ORGANISM" \
    --plus \
    --threads "$THREADS" \
    -o "${OUT_DIR}/${SAMPLE}.amrfinder.tsv" \
    2>&1 | tee "logs/amrfinder_${SAMPLE}.log"

echo "[DONE] AMRFinderPlus output: ${OUT_DIR}/${SAMPLE}.amrfinder.tsv"