#!/usr/bin/env bash
#
# kraken_bracken.sh
# Runs Kraken2 classification followed by Bracken abundance re-estimation
# on the MEGAHIT contigs.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

SAMPLE="DRR187559"
THREADS=4

CONTIGS="results/megahit_assembly/${SAMPLE}/${SAMPLE}.contigs.fa"
KRAKEN_DB="results/kraken_bracken/k2_standard_08gb"
OUT_DIR="results/kraken_bracken/${SAMPLE}"

KRAKEN_REPORT="${OUT_DIR}/${SAMPLE}.kraken2.report"
KRAKEN_OUTPUT="${OUT_DIR}/${SAMPLE}.kraken2.output"

# Read length used for Bracken's kmer distribution file.
# Kraken2 pre-built DBs ship bracken distribution files for a few fixed
# lengths (usually 50,75,100,150,200,250,300). Since we're classifying
# assembled contigs (variable length, often >>300bp), 150 is a reasonable
# generic default -- exact match matters less for long contigs than
# for short reads. Adjust READ_LEN if you want to try a different one.
READ_LEN=150

# Taxonomic level to report at: S = species, G = genus, etc.
LEVEL="S"

mkdir -p logs "$OUT_DIR"

echo "[INFO] Contigs: $CONTIGS"

if [[ ! -f "$CONTIGS" ]]; then
    echo "[ERROR] Contigs file not found at ${CONTIGS}. Run megahit_assembly.sh first."
    exit 1
fi

if [[ ! -f "${KRAKEN_DB}/hash.k2d" ]]; then
    echo "[ERROR] Kraken2 DB not found at ${KRAKEN_DB}. Did you extract the tar.gz?"
    exit 1
fi

# --- Kraken2 ---
echo "[INFO] Running Kraken2 (streams to both screen and logs/kraken_${SAMPLE}.log)"
kraken2 \
    --db "$KRAKEN_DB" \
    --threads "$THREADS" \
    --use-names \
    --report "$KRAKEN_REPORT" \
    --output "$KRAKEN_OUTPUT" \
    "$CONTIGS" \
    2>&1 | tee "logs/kraken_${SAMPLE}.log"

echo "[DONE] Kraken2 output: ${OUT_DIR}"

# --- Bracken ---
BRACKEN_DIST="${KRAKEN_DB}/database${READ_LEN}mers.kmer_distrib"
if [[ ! -f "$BRACKEN_DIST" ]]; then
    echo "[ERROR] Bracken distribution file not found at ${BRACKEN_DIST}."
    echo "        Available options:"
    ls "${KRAKEN_DB}"/database*.kmer_distrib 2>/dev/null || echo "        (none found -- DB may not include Bracken files)"
    exit 1
fi

echo "[INFO] Running Bracken (streams to both screen and logs/bracken_${SAMPLE}.log)"
bracken \
    -d "$KRAKEN_DB" \
    -i "$KRAKEN_REPORT" \
    -o "${OUT_DIR}/${SAMPLE}.bracken.output" \
    -w "${OUT_DIR}/${SAMPLE}.bracken.report" \
    -r "$READ_LEN" \
    -l "$LEVEL" \
    2>&1 | tee "logs/bracken_${SAMPLE}.log"

echo "[DONE] Bracken output: ${OUT_DIR}/${SAMPLE}.bracken.output"