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

## 🚀 Installation (5 minutes)

```bash
# 1. Clone the repository
git clone https://github.com/TU-USUARIO/bacterial-coregenome-phylo.git
cd bacterial-coregenome-phylo

# 2. Create the atmosphere with Conda
conda env create -f environment.yml

# 3. Activate the environment
conda activate bact_phylo

# 4. Verify installation
python bin/run_annotation.py --help
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
If you use this pipeline, please cite the essential tools:

- Panaroo: Tonkin-Hill et al. (2020) Genome Biology 10.1186/s13059-020-02090-4
- IQ-TREE: Minh et al. (2020) Mol Biol Evol 10.1093/molbev/msaa015

