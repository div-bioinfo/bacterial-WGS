#!/usr/bin/env bash
#
# plasmidfinder_qc.sh
# Detects plasmid replicons in the assembly.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

SAMPLE="DRR187559"

CONTIGS="results/megahit_assembly/${SAMPLE}/${SAMPLE}.contigs.fa"
PLASMID_DB="/home/divya/internship/databases/plasmidfinder_db"
OUT_DIR="results/plasmidfinder/${SAMPLE}"

# Confirmed S. aureus -> use all Gram Positive replicon family schemes
# (this DB version splits what used to be the single "gram_positive" bundle
# into individual replicon families).
DB_SCHEME="Inc18,NT_Rep,Rep1,Rep2,Rep3,RepA_N,RepL,Rep_trans"

mkdir -p logs "$OUT_DIR"

echo "[INFO] Contigs: $CONTIGS"

if [[ ! -f "$CONTIGS" ]]; then
    echo "[ERROR] Contigs file not found at ${CONTIGS}. Run megahit_assembly.sh first."
    exit 1
fi

if [[ ! -d "$PLASMID_DB" ]]; then
    echo "[ERROR] PlasmidFinder DB not found at ${PLASMID_DB}."
    exit 1
fi

echo "[INFO] Running PlasmidFinder (streams to both screen and logs/plasmidfinder_${SAMPLE}.log)"
plasmidfinder.py \
    -i "$CONTIGS" \
    -o "$OUT_DIR" \
    -p "$PLASMID_DB" \
    -d "$DB_SCHEME" \
    -x \
    2>&1 | tee "logs/plasmidfinder_${SAMPLE}.log"

echo "[DONE] PlasmidFinder output: ${OUT_DIR}"