#!/bin/bash
# run_test.sh - Prueba rápida del pipeline con genomas de ejemplo

set -e

echo "🧪 Ejecutando prueba del pipeline..."

# Crear carpeta de prueba
mkdir -p test/data
cd test

# Descargar 3 genomas pequeños de E. coli como prueba
echo "Descargando genomas de prueba (E. coli)..."
curl -L -o data/ecoli1.fasta "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/005/845/GCF_000005845.2_ASM584v2/GCF_000005845.2_ASM584v2_genomic.fna"
curl -L -o data/ecoli2.fasta "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/008/865/GCF_000008865.2_ASM886v2/GCF_000008865.2_ASM886v2_genomic.fna"
curl -L -o data/ecoli3.fasta "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/013/425/GCF_000013425.1_ASM1342v1/GCF_000013425.1_ASM1342v1_genomic.fna"

# Ejecutar pipeline en modo prueba
cd ..
echo "Ejecutando pipeline con genomas de prueba..."
bash workflows/run_full_pipeline.sh

echo "✅ Prueba completada. Revisa results/ para ver los outputs."