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
