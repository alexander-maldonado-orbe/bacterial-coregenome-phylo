#!/bin/bash
# run_panaroo.sh - Construye el pan-genoma y extrae el core-genome

set -e  # Detener si hay error

# Configuración
INPUT_GFF_DIR=$1
OUTPUT_DIR=$2
CORE_THRESHOLD=${3:-0.95}  # Default 95%

# Verificar argumentos
if [ -z "$INPUT_GFF_DIR" ] || [ -z "$OUTPUT_DIR" ]; then
    echo "Uso: bash bin/run_panaroo.sh <carpeta_con_gffs> <carpeta_salida> [core_threshold]"
    echo "Ejemplo: bash bin/run_panaroo.sh results/annotation results/panaroo 0.95"
    exit 1
fi

# Crear lista de archivos GFF
echo "Buscando archivos .gff3 en $INPUT_GFF_DIR..."
find "$INPUT_GFF_DIR" -name "*.gff3" -type f > gff_list.txt
NUM_GFFS=$(wc -l < gff_list.txt)

if [ "$NUM_GFFS" -eq 0 ]; then
    echo "Error: No se encontraron archivos .gff3 en $INPUT_GFF_DIR"
    exit 1
fi

echo "Encontrados $NUM_GFFS genomas anotados."

# Ejecutar Panaroo
echo "Ejecutando Panaroo (core threshold: $CORE_THRESHOLD)..."
panaroo \
    --input gff_list.txt \
    --out_dir "$OUTPUT_DIR" \
    --clean-mode strict \
    --core_threshold "$CORE_THRESHOLD" \
    --alignment core \
    --threads 4 \
    --remove-invalid-genes

# Verificar salida
if [ -f "$OUTPUT_DIR/core_gene_alignment.aln" ]; then
    echo "✅ Panaroo completado exitosamente"
    echo "Core-genome alineado: $OUTPUT_DIR/core_gene_alignment.aln"
    
    # Limpiar el alineamiento con ClipKIT
    echo "Limpiando alineamiento con ClipKIT..."
    clipkit "$OUTPUT_DIR/core_gene_alignment.aln" \
        -o "$OUTPUT_DIR/core_alignment_clean.fasta" \
        -m gappy
    echo "✅ Alineamiento limpio: $OUTPUT_DIR/core_alignment_clean.fasta"
else
    echo "❌ Error: No se generó core_gene_alignment.aln"
    exit 1
fi

# Limpiar archivo temporal
rm -f gff_list.txt