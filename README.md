# Bacterial Phylogeny Pipeline from Core Genome

A complete pipeline for building phylogenetic trees from bacterial core genomes. This pipeline takes multiple bacterial genome assemblies (FASTA format) and produces a phylogenetic tree based on core genome alignment.

## Features

- Genome annotation with Prokka
- Core genome identification with Roary
- Multiple sequence alignment of core genes
- Phylogenetic tree construction (IQ-TREE or FastTree)
- Tree visualization with ggtree
- Parallel processing support
- Conda environment for easy dependency management

## Requirements

- macOS M1/M2/M3 or Linux (x86_64/ARM64)
- Miniconda or Anaconda
- 8+ GB RAM (recommended)
- 10+ GB free disk space

## Quick Start

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/bacterial_phylogeny_pipeline.git
cd bacterial_phylogeny_pipeline
```

# Install conda environment
```bash
conda env create -f environment.yml
conda activate bact_phylogeny
```

# Run the pipeline
```bash
bash pipeline.sh -i /path/to/genomes/ -o output_dir
```

## Citations


```
