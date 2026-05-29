#!/bin/bash
# run_iqtree.sh - Construye el árbol filogenético con IQ-TREE

set -e

ALIGNMENT=$1
OUTPUT_PREFIX=$2
BOOTSTRAP=${3:-1000}  # Default 1000 réplicas

if [ -z "$ALIGNMENT" ] || [ -z "$OUTPUT_PREFIX" ]; then
    echo "Uso: bash bin/run_iqtree.sh <alineamiento.fasta> <prefijo_salida> [bootstrap]"
    echo "Ejemplo: bash bin/run_iqtree.sh results/panaroo/core_alignment_clean.fasta results/tree/proteus 1000"
    exit 1
fi

# Crear carpeta de salida si no existe
OUTPUT_DIR=$(dirname "$OUTPUT_PREFIX")
mkdir -p "$OUTPUT_DIR"

echo "Construyendo árbol filogenético..."
echo "  Alineamiento: $ALIGNMENT"
echo "  Bootstrap: $BOOTSTRAP"
echo "  Salida: ${OUTPUT_PREFIX}.treefile"

# Ejecutar IQ-TREE
iqtree2 \
    -s "$ALIGNMENT" \
    -m MFP \
    -B "$BOOTSTRAP" \
    -T AUTO \
    --prefix "$OUTPUT_PREFIX"

echo "✅ Árbol construido exitosamente"
echo "Árbol final: ${OUTPUT_PREFIX}.treefile"

# Mostrar estadísticas básicas
echo ""
echo "Estadísticas del árbol:"
nw_stats "${OUTPUT_PREFIX}.treefile" | head -10 2>/dev/null || echo "  (instalar newick-utils para estadísticas detalladas)"