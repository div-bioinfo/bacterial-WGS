# MRSA WGS Pipeline

A bacterial whole-genome sequencing analysis pipeline, built as a set of
individually-runnable shell scripts covering raw read QC through assembly, taxonomic classification, 
and functional/AMR annotation. Applied here to a clinical MRSA isolate as a worked example.

## Dataset

- **Accession**: [DRR187559](https://www.ncbi.nlm.nih.gov/sra/DRR187559) (experiment DRX178031, sample SAMD00180470)
- **Organism**: *Staphylococcus aureus* strain KUN1163 (MRSA)
- **Study**: PRJDB8599 — "Complete Genome Sequence of 8 methicillin-resistant *Staphylococcus aureus* Strains" (Hikichi et al.)
- **Platform**: Illumina MiSeq, paired-end (2×301bp)
- **Size**: 451,782 read pairs, ~114MB compressed

## Pipeline

Each stage is a standalone bash script under `scripts/`, reading from
the previous stage's `results/` subfolder and writing to its own.

| Stage | Script | Tool | Purpose |
|---|---|---|---|
| 1 | `make_dirs.sh` | — | Scaffold the results folder structure |
| 2 | — | SRA Toolkit / ENA | Download raw FASTQ |
| 3 | `fastp_trim.sh` | fastp | Adapter/quality trimming |
| 4 | `postrim_qc.sh` | FastQC + MultiQC | Pre- and post-trim FastQC, aggregated MultiQC report |
| 5 | `megahit_assembly.sh` | MEGAHIT | De novo assembly |
| 6 | `busco_qc.sh` | BUSCO | Assembly completeness (auto-lineage, prokaryote) |
| 7 | `quast_qc.sh` | QUAST | Assembly contiguity/quality metrics |
| 8 | `kraken_bracken.sh` | Kraken2 + Bracken | Taxonomic classification of assembly contigs |
| 9 | `bakta_annotation.sh` | Bakta | Gene prediction & annotation |
| 10 | `plasmidfinder_qc.sh` | PlasmidFinder | Plasmid replicon typing |
| 11 | `amrfinder_qc.sh` | AMRFinderPlus | AMR gene, virulence & point-mutation detection |

All scripts anchor to the project root automatically (via `$BASH_SOURCE`),
so they can be run from anywhere:

```bash
bash scripts/make_dirs.sh
bash scripts/fastp_trim.sh
bash scripts/postrim_qc.sh
bash scripts/megahit_assembly.sh
bash scripts/busco_qc.sh
bash scripts/quast_qc.sh
bash scripts/kraken_bracken.sh
bash scripts/bakta_annotation.sh
bash scripts/plasmidfinder_qc.sh
bash scripts/amrfinder_qc.sh
```

## Environment

Multiple conda environments were used across this pipeline (some tools —
BUSCO, PlasmidFinder, Kraken2/Bracken in particular — have dependency
requirements that conflict when installed together). `envs/environment.yml`
lists the full toolset for reference; you may need to split it into
per-tool environments depending on your platform. Databases required and
**not included** in this repo (all downloaded separately, see each tool's
docs): BUSCO lineage sets, the Kraken2 Standard-8 database, the
PlasmidFinder database, the AMRFinderPlus database.

## Assembly summary

| Metric | Value |
|---|---|
| Total length | 2,902,476 bp |
| Contigs | 62 (56 ≥500 bp) |
| GC content | 32.8% |
| N50 / N90 | 99,899 bp / 34,903 bp |
| L50 | 8 |
| Largest contig | 386,595 bp |
| CDS | 2,709 |
| tRNAs / rRNAs / ncRNAs | 44 / 7 / 93 |
| Hypothetical proteins | 210 |

## Key findings

- **Species confirmation**: Kraken2/Bracken classified all 62 contigs
  within the *Staphylococcus* lineage, with the majority resolving to
  *Staphylococcus aureus* at the species level after Bracken
  re-estimation (100%). Genome size (~2.9 Mb) and GC content (32.8%) are
  both consistent with reference *S. aureus* values, corroborating the
  taxonomic call independently of the classifier.

- **Assembly quality**: N50 of ~100 kb across 56 contigs (≥500 bp) with
  zero ambiguous bases indicates a contiguous, clean short-read assembly,
  suitable for downstream annotation and gene-content analysis (though
  not chromosome-resolved).

- **AMR profile**: Confirmed resistance determinants for **tetracycline**
  (`tet(M)`), **macrolides/lincosamides/streptogramin B** (`erm(A)`), and
  **spectinomycin** (`ant(9)-Ia`), plus a multidrug efflux transporter
  (`mepA`) associated with reduced tigecycline/biocide susceptibility.
  All hits were exact or near-exact matches (≥99% identity) to curated
  reference sequences.

- **Virulence factors**: An extensive toxin repertoire consistent with a
  clinical isolate, including the enterotoxin gene cluster (egc: `seo`,
  `sem`, `sei`, `seu`) plus additional standalone enterotoxins (`seb`,
  `selX`), the cytotoxin `aur` (aureolysin) and `hld` (delta-hemolysin),
  and the biofilm-associated adhesin gene `icaC`.

- **Plasmid content**: PlasmidFinder identified four Gram-positive
  replicon types (Inc18, Rep1, Rep3, RepA_N) plus a conjugative-type
  replicon (Rep_trans). Notably, a ~100 kb contig (`k141_23`) — the
  largest in the assembly — carries the Rep_trans replicon, an oriT
  (conjugative transfer origin, per Bakta), and two AMR genes (`mepA`,
  `tet(M)`), consistent with a large conjugative resistance plasmid
  rather than chromosomal sequence.

- **Annotation caveat**: Bakta predicted 4 origins of replication (oriC),
  whereas a bacterial chromosome carries exactly one. This is interpreted
  as an artifact of assembly fragmentation (dnaA-adjacent motifs
  misidentified across multiple contigs) rather than genuine biology, and
  is flagged here rather than reported as a finding