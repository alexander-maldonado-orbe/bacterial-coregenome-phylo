# Installation Guide

## For macOS M1/M2/M3

### 1. Install Miniconda
```bash
# Download and install Miniconda for Apple Silicon
curl -L https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh -o miniconda.sh
bash miniconda.sh -b -p $HOME/miniconda
source $HOME/miniconda/bin/activate
conda init
```

## For Linux (x86_64)
### 1. Install Miniconda
```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
bash miniconda.sh -b -p $HOME/miniconda
source $HOME/miniconda/bin/activate
conda init
```

### 2. Clone repository and install environment
```bash
git clone https://github.com/alexander-maldonado-orbe/bacterial_phylogeny_pipeline.git
cd bacterial_phylogeny_pipeline

# Create conda environment (may take 10-15 minutes)
conda env create -f environment.yml
conda activate bact_phylogeny
```
### 3. Make pipeline executable
```bash
chmod +x pipeline.sh
chmod +x scripts/*.py
```

## For Linux (ARM64 - e.g., AWS Graviton, Raspberry Pi)
### 1. Install Miniconda
```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh -O miniconda.sh
bash miniconda.sh -b -p $HOME/miniconda
source $HOME/miniconda/bin/activate
conda init
```

### 2. Clone repository and install environment
```bash
git clone https://github.com/alexander-maldonado-orbe/bacterial_phylogeny_pipeline.git
cd bacterial_phylogeny_pipeline

# Create conda environment (may take 10-15 minutes)
conda env create -f environment.yml
conda activate bact_phylogeny
```
### 3. Make pipeline executable
```bash
chmod +x pipeline.sh
chmod +x scripts/*.py
```

## Verifying and Testing the installation
Run this quick check to ensure everything is installed correctly:
```bash
conda activate bact_phylogeny

# Check versions
prokka --version
roary --version
mafft --version
iqtree2 --version 2>/dev/null || echo "IQ-TREE installed"
FastTreeMP -help 2>&1 | head -1

# Python package check
python -c "import Bio; import pandas; print('Python packages OK')"
```

## Troubleshooting Common Issues

### Issue 1: Prokka fails with "Prokka needs blastp 2.2 or higher"
**Solution:** 
```bash
conda install -c bioconda blast=2.9.0
conda install -c bioconda prokka=1.14.6
```

### Issue 2: Roary fails with Perl module errors
```bash
conda install -c conda-forge perl-file-find-rule perl-file-slurp
cpanm File::Find::Rule
```

### Issue 3: No core genes found (empty alignment)

This is NORMAL for diverse genomes. Solutions:
- Use more closely related strains (same species, same pathotype)
- Lower the core percentage threshold: -cd 30 (30% of strains)
- Use Parsnp instead for diverse genomes:
```bash
conda install -c bioconda parsnp
parsnp -r reference.fna -d genomes/ -p 8 -o output/
```

### Issue 4: Memory errors
Solution: Reduce threads and process fewer genomes:
```bash
./pipeline.sh -i genomes/ -o output/ -t 2
```

### Issue 5: Conda environment creation fails
Solution: Use mamba instead:
```bash
conda install -c conda-forge mamba
mamba env create -f environment.yml
```
