# bacterial-coregenome-phylo
Reproducible pipeline for core-genome-based bacterial phylogenomics. Designed for Mac M1/M2 and Linux.

# Bacterial Core-genome Phylogeny Pipeline

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Conda](https://img.shields.io/badge/conda-24.1.2-green)](https://docs.conda.io/)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-blue)]()

Pipeline reproducible y automatizado para construir árboles filogenéticos de alta calidad a partir del **core-genoma** de bacterias.

## 🎯 ¿Para qué sirve?

Este pipeline toma genomas bacterianos ensamblados (en formato `.fasta`) y produce:
- Un árbol filogenético de máxima verosimilitud basado en el core-genome
- Visualizaciones del árbol en PDF
- Archivos intermedios para análisis posteriores

## 📦 Requisitos

- **macOS** (Apple Silicon M1/M2/M3 o Intel) o **Linux** (Ubuntu 20.04+)
- **Mínimo 8GB de RAM** (recomendado 16GB para >50 genomas)
- **Conda/Mamba** instalado

## 🚀 Instalación (5 minutos)

```bash
# 1. Clonar el repositorio
git clone https://github.com/TU-USUARIO/bacterial-coregenome-phylo.git
cd bacterial-coregenome-phylo

# 2. Crear el ambiente con Conda
conda env create -f environment.yml

# 3. Activar el ambiente
conda activate bact_phylo

# 4. Verificar instalación
python bin/run_annotation.py --help
