#!/usr/bin/env bash
#
# busco_qc.sh
# Runs BUSCO completeness assessment on the MEGAHIT contigs.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

SAMPLE="DRR187559"
THREADS=4

CONTIGS="results/megahit_assembly/${SAMPLE}/${SAMPLE}.contigs.fa"
BUSCO_DIR="results/busco"

mkdir -p logs "$BUSCO_DIR"

echo "[INFO] Contigs: $CONTIGS"

if [[ ! -f "$CONTIGS" ]]; then
    echo "[ERROR] Contigs file not found at ${CONTIGS}. Run megahit_assembly.sh first."
    exit 1
fi

# --auto-lineage-prok since this is a bacterial genome (skips checking
# eukaryote datasets, faster than the generic --auto-lineage). Swap for
# a specific lineage (e.g. -l staphylococcales_odb10) if you'd rather
# skip auto-placement and already know the taxon.
echo "[INFO] Running BUSCO (streams to both screen and logs/busco_${SAMPLE}.log)"
busco \
    -i "$CONTIGS" \
    -o "$SAMPLE" \
    --out_path "$BUSCO_DIR" \
    -m genome \
    --auto-lineage-prok \
    -c "$THREADS" \
    -f \
    2>&1 | tee "logs/busco_${SAMPLE}.log"

echo "[DONE] BUSCO output: ${BUSCO_DIR}/${SAMPLE}"
