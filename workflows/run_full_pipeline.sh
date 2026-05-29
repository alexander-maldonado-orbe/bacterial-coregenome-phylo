#!/bin/bash
# run_full_pipeline.sh - Ejecuta todo el flujo de principio a fin

set -e  # Detener en cualquier error

echo "========================================="
echo "  Core-genome Phylogeny Pipeline"
echo "  para Bacterias"
echo "========================================="
echo ""

# Verificar ambiente conda
if [[ -z "$CONDA_DEFAULT_ENV" ]] || [[ "$CONDA_DEFAULT_ENV" != "bact_phylo" ]]; then
    echo "⚠️  Activando ambiente conda 'bact_phylo'..."
    source $(conda info --base)/etc/profile.d/conda.sh
    conda activate bact_phylo
fi

# Verificar que existan los genomas
if [ ! -d "data/raw_genomes" ]; then
    echo "❌ Error: Carpeta 'data/raw_genomes' no encontrada"
    echo "Por favor, crea 'data/raw_genomes/' y coloca tus genomas .fasta allí"
    exit 1
fi

NUM_GENOMAS=$(ls data/raw_genomes/*.fasta 2>/dev/null | wc -l)
if [ "$NUM_GENOMAS" -eq 0 ]; then
    echo "❌ Error: No se encontraron archivos .fasta en data/raw_genomes/"
    exit 1
fi

echo "📊 Encontrados $NUM_GENOMAS genomas para analizar"
echo ""

# Paso 1: Anotación
echo "=== PASO 1: Anotación con Bakta ==="
python bin/run_annotation.py --input data/raw_genomes --output results/01_annotation --db light
echo ""

# Paso 2: Panaroo (core-genome)
echo "=== PASO 2: Core-genome con Panaroo ==="
bash bin/run_panaroo.sh results/01_annotation results/02_panaroo 0.95
echo ""

# Paso 3: Árbol filogenético
echo "=== PASO 3: Árbol filogenético con IQ-TREE ==="
bash bin/run_iqtree.sh results/02_panaroo/core_alignment_clean.fasta results/03_tree/phylogeny 1000
echo ""

# Paso 4: Visualización
echo "=== PASO 4: Visualización del árbol ==="
Rscript bin/plot_tree.R results/03_tree/phylogeny.treefile "Filogenia de $NUM_GENOMAS genomas" results/phylogenetic_tree.pdf
echo ""

echo "========================================="
echo "  ✅ PIPELINE COMPLETADO EXITOSAMENTE"
echo "========================================="
echo ""
echo "Resultados principales:"
echo "  📁 Anotaciones: results/01_annotation/"
echo "  📁 Pan-genoma: results/02_panaroo/"
echo "  🌳 Árbol Newick: results/03_tree/phylogeny.treefile"
echo "  📊 Visualización PDF: results/phylogenetic_tree.pdf"
echo "  📊 Visualización lineal: results/phylogenetic_tree_linear.pdf"
echo ""
echo "Para visualizar interactivamente, sube a: https://itol.embl.de/"
