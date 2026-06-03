#!/bin/bash
# Main pipeline script for bacterial core genome phylogeny

set -euo pipefail

# Default parameters
INPUT_DIR=""
OUTPUT_DIR="phylogeny_results"
THREADS=4
TREE_METHOD="iqtree"
PREFIX="core_genome"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--input)
            INPUT_DIR="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -t|--threads)
            THREADS="$2"
            shift 2
            ;;
        -m|--method)
            TREE_METHOD="$2"
            shift 2
            ;;
        -p|--prefix)
            PREFIX="$2"
            shift 2
            ;;
        -h|--help)
            cat << EOF
Bacterial Phylogeny Pipeline from Core Genome

Usage: $0 [options]

Options:
    -i, --input DIR      Input directory containing genome FASTA files
    -o, --output DIR     Output directory (default: phylogeny_results)
    -t, --threads NUM    Number of CPU threads (default: 4)
    -m, --method TOOL    Tree building method: iqtree or fasttree (default: iqtree)
    -p, --prefix STR     Output prefix (default: core_genome)
    -h, --help           Show this help message

Example:
    $0 -i genomes/ -o results/ -t 8 -m iqtree
EOF
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Validate input
if [[ -z "$INPUT_DIR" ]]; then
    echo "Error: Input directory not specified"
    exit 1
fi

if [[ ! -d "$INPUT_DIR" ]]; then
    echo "Error: Input directory $INPUT_DIR does not exist"
    exit 1
fi

# Create output directories
mkdir -p "$OUTPUT_DIR"/{prokka,roary,core_alignment,trees,logs,reports}

# Set up logging
LOG_FILE="$OUTPUT_DIR/logs/pipeline_$(date +%Y%m%d_%H%M%S).log"
exec 1> >(tee -a "$LOG_FILE")
exec 2>&1

echo "=== Bacterial Phylogeny Pipeline ==="
echo "Start time: $(date)"
echo "Input directory: $INPUT_DIR"
echo "Output directory: $OUTPUT_DIR"
echo "Threads: $THREADS"
echo "Tree method: $TREE_METHOD"
echo "Log file: $LOG_FILE"
echo ""

# Step 1: Check input files
echo "Step 1: Validating input files..."
python "$SCRIPT_DIR/scripts/utils.py" check_inputs "$INPUT_DIR" || exit 1

# Step 2: Run Prokka annotation
echo "Step 2: Annotating genomes with Prokka..."
python "$SCRIPT_DIR/scripts/run_prokka.py" \
    --input "$INPUT_DIR" \
    --output "$OUTPUT_DIR/prokka" \
    --threads "$THREADS" || exit 1

# Step 3: Run Roary for core genome
echo "Step 3: Identifying core genome with Roary..."
python "$SCRIPT_DIR/scripts/run_roary.py" \
    --input "$OUTPUT_DIR/prokka" \
    --output "$OUTPUT_DIR/roary" \
    --threads "$THREADS" || exit 1

# Step 4: Generate core genome alignment
echo "Step 4: Generating core genome alignment..."
python "$SCRIPT_DIR/scripts/core_alignment.py" \
    --roary "$OUTPUT_DIR/roary" \
    --output "$OUTPUT_DIR/core_alignment" \
    --prefix "$PREFIX" || exit 1

# Step 5: Build phylogenetic tree
echo "Step 5: Building phylogenetic tree with $TREE_METHOD..."
python "$SCRIPT_DIR/scripts/build_tree.py" \
    --alignment "$OUTPUT_DIR/core_alignment/${PREFIX}_core_alignment.fasta" \
    --output "$OUTPUT_DIR/trees" \
    --method "$TREE_METHOD" \
    --threads "$THREADS" \
    --prefix "$PREFIX" || exit 1

# Step 6: Generate summary report
echo "Step 6: Generating summary report..."
python "$SCRIPT_DIR/scripts/utils.py" report \
    --roary "$OUTPUT_DIR/roary" \
    --tree "$OUTPUT_DIR/trees/${PREFIX}_tree.nwk" \
    --output "$OUTPUT_DIR/reports/summary.html" || exit 1

echo ""
echo "=== Pipeline completed successfully ==="
echo "End time: $(date)"
echo "Results available in: $OUTPUT_DIR"
echo "Tree file: $OUTPUT_DIR/trees/${PREFIX}_tree.nwk"
echo "Summary report: $OUTPUT_DIR/reports/summary.html"
