# Installation Guide

## For macOS M1/M2/M3

### 1. Install Miniconda
```bash
# Download and install Miniconda for Apple Silicon
curl -L https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh -o miniconda.sh
bash miniconda.sh -b -p $HOME/miniconda
source $HOME/miniconda/bin/activate
conda init