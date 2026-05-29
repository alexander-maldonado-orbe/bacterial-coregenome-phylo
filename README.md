# bacterial-coregenome-phylo
Reproducible pipeline for core-genome-based bacterial phylogenomics. Designed for Mac M1/M2 and Linux.

# Bacterial Core-genome Phylogeny Pipeline

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Conda](https://img.shields.io/badge/conda-24.1.2-green)](https://docs.conda.io/)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-blue)]()

Reproducible and automated pipeline for building high-quality phylogenetic trees from the **core-genome** of bacteria.

## 🎯 What is it for?

This pipeline takes assembled bacterial genomes (in `.fasta` format) and produces:
- A maximum likelihood phylogenetic tree based on the core genome
- PDF visualizations of the tree
- Intermediate files for further analysis
  
## 📦 Requirements

- **macOS** (Apple Silicon M1/M2/M3 or Intel) or **Linux** (Ubuntu 20.04+)
- **Minimum 8GB of RAM** (16GB recommended for >50 genomes)
- **Conda/Mamba** installed

## Run the Pipeline

### Option 1: Google Colab (Recommended - No installation required)

[![Open in Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/alexander-maldonado-orbe/bacterial-coregenome-phylo/blob/main/pipeline.ipynb)

1. Click the button above
2. Go to `Runtime Environment` → `Run all`
3. Upload your genomes
4. Download the results

### Option 2: Local Installation (Linux or HPC)

```bash
git clone https://github.com/alexander-maldonado-orbe/bacterial-coregenome-phylo.git
cd bacterial-coregenome-phylo
conda env create -f environment.yml
conda activate bact_phylo
bash workflows/run_full_pipeline.sh
```

## Input Data Structure
Place your genomes in .fasta format in:

```text
your_project/
└── data/
    └── raw_genomes/
        ├── strain1.fasta
        ├── strain2.fasta
        ├── reference.fasta
        └── outgroup.fasta  # Important: Include an external group
```

## Pipeline execution

```bash
# Run the entire pipeline
bash workflows/run_full_pipeline.sh
```

## Interpretation of results

| File | Description |
| :--- | :---: |
| results/03_tree/phylogeny.treefile | Tree in Newick format (for iTOL/FigTree) |
| results/phylogenetic_tree.pdf | Circular visualization of the tree |
| results/02_panaroo/ | Pan-genome and core-genome tables |

## Try with sample data
```bash
bash test/run_test.sh
```

## Citations
### If you use this pipeline, please cite the essential tools:

- **Panaroo**: Tonkin-Hill, G., et al. (2020). Producing polished prokaryotic pangenomes with the Panaroo pipeline. *Genome Biology*, 21(1), 180. [10.1186/s13059-020-02090-4](https://doi.org/10.1186/s13059-020-02090-4)

- **IQ-TREE 2**: Minh, B. Q., et al. (2020). IQ-TREE 2: New models and efficient methods for phylogenetic inference in the genomic era. *Molecular Biology and Evolution*, 37(5), 1530-1534. [10.1093/molbev/msaa015](https://doi.org/10.1093/molbev/msaa015)

- **Bakta**: Schwengers, O., et al. (2021). Bakta: rapid and standardized annotation of bacterial genomes via alignment-free sequence identification. *Microbial Genomics*, 7(11). [10.1099/mgen.0.000685](https://doi.org/10.1099/mgen.0.000685)

- **ClipKIT**: Steenwyk, J. L., et al. (2020). ClipKIT: A multiple sequence alignment trimming software for phylogenomics. *PLoS Biology*, 18(8), e3001007. [10.1371/journal.pbio.3001007](https://doi.org/10.1371/journal.pbio.3001007)

### If you use this pipeline for a specific study, please also cite:
```bibtext
@misc{Maldonado2026,
  author = {Maldonado, A},
  title = {bacterial-coregenome-phylo: A pipeline for bacterial core-genome phylogenomics},
  year = {2026},
  publisher = {GitHub},
  url = {https://github.com/alexander-maldonado-orbe/bacterial-coregenome-phylo},
  version = {1.0.0}
}
```
