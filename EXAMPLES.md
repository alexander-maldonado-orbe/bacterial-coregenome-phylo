# Examples

## Example 1: Analyzing Proteus mirabilis (Lab + NCBI Genomes)

This example shows how to analyze 57 Proteus mirabilis genomes (7 lab isolates + 50 NCBI genomes).

### Step 1: Organize your genomes

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
