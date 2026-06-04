# Examples

# Example 1: Analyzing Proteus mirabilis (Lab + NCBI Genomes)

This example shows how to analyze 57 Proteus mirabilis genomes (7 lab isolates + 50 NCBI genomes).

## Step 1: Organize your genomes

```bash
# Create project directory
mkdir -p proteus_project/genomes
cd proteus_project

# Copy your lab assemblies
cp /path/to/lab_isolates/*.fna genomes/

# Download NCBI genomes
# Method 1: Using ncbi-genome-download
conda install -c bioconda ncbi-genome-download
ncbi-genome-download -F fasta -s refseq -o genomes/ "Proteus mirabilis"

# Method 2: Manual download with accession list
cat > accessions.txt << 'EOF'
GCF_000009205.1
GCF_000009225.1
# ... add your 50 accession numbers
EOF

while read accession; do
    wget "https://ftp.ncbi.nlm.nih.gov/genomes/all/${accession:0:3}/${accession:0:6}/${accession}/${accession}*.fna.gz"
done < accessions.txt
```

## Step 2: Run the pipeline
```bash
# Activate environment
conda activate bact_phylogeny

# Run pipeline on all 57 genomes
./pipeline.sh \
    -i genomes/ \
    -o results \
    -t 8 \
    -m fasttree \
    -p proteus_mirabilis \
    -cd 95
```

## Step 3: Expected results
- Annotation: 57 genomes annotated (5-10 min each)
- Core genes: 2,000-3,000 genes present in >95% of strains
- Tree: Shows relationship between lab isolates and NCBI references
- Runtime: 4-8 hours on 8 CPUs

## Step 4: Visualize results
# View tree
cat results/trees/proteus_mirabilis_tree.nwk

# Create colored tree by source
```bash
python << 'EOF'
from Bio import Phylo
import matplotlib.pyplot as plt

tree = Phylo.read("results/trees/proteus_mirabilis_tree.nwk", "newick")
fig, ax = plt.subplots(figsize=(20, 30))
Phylo.draw(tree, axes=ax)
plt.savefig("proteus_tree.png", dpi=300)
EOF
```

# Example 2: Analyzing Only NCBI Genomes
```bash
# Download 50 E. coli genomes
mkdir -p ecoli_project/genomes
cd ecoli_project

# Download using NCBI datasets
conda install -c conda-forge ncbi-datasets-cli
datasets download genome taxon "Escherichia coli" --refseq --assembly-level complete

# Run pipeline
../bacterial_phylogeny_pipeline/pipeline.sh \
    -i genomes/ \
    -o results \
    -t 8 \
    -m fasttree \
    -p ecoli_50strains \
    -cd 95
```

# Example 3: Analyzing Only Lab Isolates
```bash
# Run on 10 lab isolates
./pipeline.sh \
    -i my_lab_genomes/ \
    -o lab_results \
    -t 4 \
    -m iqtree \
    -p lab_isolates \
    -cd 98  # Stricter core for closely related strains
```
