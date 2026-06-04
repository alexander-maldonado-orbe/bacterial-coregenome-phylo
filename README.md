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

## Usage
```bash
bash pipeline.sh [options]

Options:
  -i, --input DIR      Input directory containing genome FASTA files
  -o, --output DIR     Output directory (default: phylogeny_results)
  -t, --threads NUM    Number of CPU threads (default: 4)
  -m, --method TOOL    Tree building method: iqtree or fasttree (default: iqtree)
  -p, --prefix STR     Output prefix (default: core_genome)
  -h, --help           Show this help message
```

## Output
### Pipeline Steps
1. **Quality check:** Verify input files
2. **Annotation:** Prokka annotation of all genomes
3. **Core genome:** Roary pangenome analysis
4. **Alignment:** MAFFT alignment of core genes
5. **Tree building:** Maximum likelihood phylogeny
6. **Visualization:** Basic tree plots (optional)

```txt
output_dir/
├── prokka/          # Annotated genomes
├── roary/           # Roary output and core genome
├── core_alignment/  # Core genome alignment files
├── trees/           # Phylogenetic trees (Newick format)
├── logs/            # Pipeline logs
└── reports/         # Summary reports
```

## Example
```bash
# Run with 8 threads using IQ-TREE
bash pipeline.sh -i my_genomes/ -o my_results/ -t 8 -m iqtree
```

## Clone repository and install environment
```bash
# Clone the repository
git clone https://github.com/alexander-maldonado-orbe/bacterial_phylogeny_pipeline.git
cd bacterial_phylogeny_pipeline

# Create conda environment
conda env create -f environment.yml
conda activate bact_phylogeny
```
## Make pipeline executable
```bash
chmod +x pipeline.sh
chmod +x scripts/*.py
```

## Test with sample data
```bash
mkdir test_genomes

# Create or download some test genome files (FASTA format)
# Example: download E. coli genomes from NCBI
wget -P test_genomes/ https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/005/845/GCF_000005845.2_ASM584v2/GCF_000005845.2_ASM584v2_genomic.fna.gz
gunzip test_genomes/*.gz

# Run pipeline with test data
./pipeline.sh -i test_genomes -o test_output -t 2 -m fasttree
```

### Run the pipeline
```bash
# For closely related strains (default)
./pipeline.sh -i genomes/ -o results/

# For moderately diverse strains
./pipeline.sh -i genomes/ -o results/ -cd 30

# For diverse strains
./pipeline.sh -i genomes/ -o results/ -cd 20 -m fasttree
```
The pipeline will automatically try lower thresholds and Parsnp if needed

## Citation
If you use this pipeline, please cite:

- Seemann T. (2014). Prokka: rapid prokaryotic genome annotation. Bioinformatics (Oxford, England), 30(14), 2068–2069. https://doi.org/10.1093/bioinformatics/btu153
- Page, A. J., Cummins, C. A., Hunt, M., Wong, V. K., Reuter, S., Holden, M. T., Fookes, M., Falush, D., Keane, J. A., & Parkhill, J. (2015). Roary: rapid large-scale prokaryote pan genome analysis. Bioinformatics (Oxford, England), 31(22), 3691–3693. https://doi.org/10.1093/bioinformatics/btv421
- Minh, B. Q., Schmidt, H. A., Chernomor, O., Schrempf, D., Woodhams, M. D., von Haeseler, A., & Lanfear, R. (2020). IQ-TREE 2: New Models and Efficient Methods for Phylogenetic Inference in the Genomic Era. Molecular biology and evolution, 37(5), 1530–1534. https://doi.org/10.1093/molbev/msaa015

```
