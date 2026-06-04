#!/bin/bash
# Bacterial Phylogeny Pipeline from Core Genome
# Updated with fallback strategies and better error handling

set -euo pipefail

# Global variables
INPUT_DIR=""
OUTPUT_DIR="phylogeny_results"
THREADS=4
TREE_METHOD="iqtree"
PREFIX="core_genome"
CORE_PERCENT=50
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if core alignment is valid
check_core_alignment() {
    local alignment_file="$1"
    
    if [ ! -f "$alignment_file" ]; then
        return 1
    fi
    
    # Check file size (should be at least 100 bytes for a valid alignment)
    local file_size=$(stat -c%s "$alignment_file" 2>/dev/null || stat -f%z "$alignment_file" 2>/dev/null)
    
    if [ "$file_size" -lt 100 ]; then
        print_warning "Core alignment file is too small (${file_size} bytes)"
        return 1
    fi
    
    # Check if alignment has actual sequences (not just headers)
    local seq_count=$(grep -c "^>" "$alignment_file" 2>/dev/null || echo "0")
    if [ "$seq_count" -lt 2 ]; then
        print_warning "Core alignment has less than 2 sequences"
        return 1
    fi
    
    return 0
}

# Function to run Parsnp as fallback for diverse genomes
run_parsnp_fallback() {
    print_warning "Genomes appear to be diverse. Trying Parsnp fallback..."
    
    # Check if Parsnp is installed
    if ! command -v parsnp &> /dev/null; then
        print_status "Installing Parsnp..."
        conda install -c bioconda parsnp -y || {
            print_error "Failed to install Parsnp"
            return 1
        }
    fi
    
    # Create Parsnp output directory
    local parsnp_output="$OUTPUT_DIR/parsnp_fallback"
    mkdir -p "$parsnp_output"
    
    # Find reference genome (first genome in input directory)
    local reference=$(find "$INPUT_DIR" -maxdepth 1 -name "*.fna" -o -name "*.fasta" | head -1)
    
    if [ -z "$reference" ]; then
        print_error "No reference genome found for Parsnp"
        return 1
    fi
    
    print_status "Running Parsnp with reference: $(basename "$reference")"
    
    # Run Parsnp
    parsnp -r "$reference" \
           -d "$INPUT_DIR" \
           -p "$THREADS" \
           -o "$parsnp_output" \
           -c 2>&1 | tee -a "$OUTPUT_DIR/logs/parsnp.log"
    
    # Check if tree was created
    if [ -f "$parsnp_output/parsnp.tree" ]; then
        cp "$parsnp_output/parsnp.tree" "$OUTPUT_DIR/trees/${PREFIX}_tree.nwk"
        print_status "✓ Fallback tree built successfully with Parsnp"
        return 0
    else
        print_error "Parsnp fallback failed to produce a tree"
        return 1
    fi
}

# Function to try alternative core percentages with Roary
try_alternative_core_percentages() {
    local gff_list="$1"
    local output_roary="$2"
    
    local percentages=(50 30 20 10)
    
    for percent in "${percentages[@]}"; do
        print_status "Trying Roary with ${percent}% core threshold..."
        
        local test_output="${output_roary}_core${percent}"
        
        roary -f "$test_output" \
              -p "$THREADS" \
              -e \
              -v \
              --mafft \
              -cd "$percent" \
              -i 80 \
              $(cat "$gff_list") 2>&1 | tail -20
        
        if [ -f "$test_output/core_gene_alignment.aln" ]; then
            local size=$(stat -c%s "$test_output/core_gene_alignment.aln" 2>/dev/null || stat -f%z "$test_output/core_gene_alignment.aln" 2>/dev/null)
            if [ "$size" -gt 100 ]; then
                print_status "✓ Found valid core alignment with ${percent}% threshold (size: ${size} bytes)"
                # Copy successful output to main roary directory
                cp -r "$test_output"/* "$output_roary/" 2>/dev/null
                return 0
            fi
        fi
    done
    
    return 1
}

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
        -cd|--core-percent)
            CORE_PERCENT="$2"
            shift 2
            ;;
        -h|--help)
            cat << EOF
Bacterial Phylogeny Pipeline from Core Genome

Usage: $0 [options]

Options:
    -i, --input DIR          Input directory containing genome FASTA files
    -o, --output DIR         Output directory (default: phylogeny_results)
    -t, --threads NUM        Number of CPU threads (default: 4)
    -m, --method TOOL        Tree building method: iqtree or fasttree (default: iqtree)
    -p, --prefix STR         Output prefix (default: core_genome)
    -cd, --core-percent NUM  Core gene percentage threshold (default: 50, lower = more tolerant)
    -h, --help               Show this help message

Example:
    $0 -i genomes/ -o results/ -t 8 -m fasttree -cd 30

Note: For diverse genomes, use lower core percentage (-cd 30 or -cd 20)
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
    print_error "Input directory not specified"
    exit 1
fi

if [[ ! -d "$INPUT_DIR" ]]; then
    print_error "Input directory $INPUT_DIR does not exist"
    exit 1
fi

# Create output directories
mkdir -p "$OUTPUT_DIR"/{prokka,roary,core_alignment,trees,logs,reports}

# Set up logging
LOG_FILE="$OUTPUT_DIR/logs/pipeline_$(date +%Y%m%d_%H%M%S).log"
exec 1> >(tee -a "$LOG_FILE")
exec 2>&1

echo "========================================="
echo "  Bacterial Phylogeny Pipeline"
echo "========================================="
echo "Start time: $(date)"
echo "Input directory: $INPUT_DIR"
echo "Output directory: $OUTPUT_DIR"
echo "Threads: $THREADS"
echo "Tree method: $TREE_METHOD"
echo "Core percentage threshold: ${CORE_PERCENT}%"
echo "Log file: $LOG_FILE"
echo "========================================="
echo ""

# Step 1: Check input files
print_status "Step 1: Validating input files..."
python "$SCRIPT_DIR/scripts/utils.py" check_inputs "$INPUT_DIR" || exit 1

# Count genomes
NUM_GENOMES=$(find "$INPUT_DIR" -maxdepth 1 -type f \( -name "*.fna" -o -name "*.fasta" -o -name "*.fa" \) | wc -l)
print_status "Found $NUM_GENOMES genome files"

# Step 2: Run Prokka annotation
print_status "Step 2: Annotating genomes with Prokka..."
python "$SCRIPT_DIR/scripts/run_prokka.py" \
    --input "$INPUT_DIR" \
    --output "$OUTPUT_DIR/prokka" \
    --threads "$THREADS" || {
        print_error "Prokka annotation failed"
        exit 1
    }

# Check if Prokka succeeded
GFF_COUNT=$(find "$OUTPUT_DIR/prokka" -name "*.gff" | wc -l)
if [ "$GFF_COUNT" -lt 2 ]; then
    print_error "Prokka produced less than 2 GFF files. Check your input genomes."
    exit 1
fi
print_status "Prokka completed: $GFF_COUNT GFF files created"

# Step 3: Run Roary for core genome
print_status "Step 3: Identifying core genome with Roary..."

# Create GFF list
GFF_LIST="$OUTPUT_DIR/prokka/gff_list.txt"
find "$OUTPUT_DIR/prokka" -name "*.gff" > "$GFF_LIST"

# Try Roary with user-specified core percentage
ROARY_OUTPUT="$OUTPUT_DIR/roary"
mkdir -p "$ROARY_OUTPUT"

print_status "Running Roary with ${CORE_PERCENT}% core threshold..."
roary -f "$ROARY_OUTPUT" \
      -p "$THREADS" \
      -e \
      -v \
      --mafft \
      -cd "$CORE_PERCENT" \
      -i 80 \
      $(cat "$GFF_LIST") 2>&1 | tee -a "$OUTPUT_DIR/logs/roary.log"

# Check if Roary produced a valid core alignment
CORE_ALN="$ROARY_OUTPUT/core_gene_alignment.aln"
if ! check_core_alignment "$CORE_ALN"; then
    print_warning "Roary with ${CORE_PERCENT}% core threshold did not produce valid alignment"
    
    # Try alternative core percentages
    if try_alternative_core_percentages "$GFF_LIST" "$ROARY_OUTPUT"; then
        print_status "✓ Found working core percentage"
        CORE_ALN="$ROARY_OUTPUT/core_gene_alignment.aln"
    else
        print_warning "No valid core alignment found with Roary"
        
        # Try Parsnp fallback
        if run_parsnp_fallback; then
            print_status "Pipeline completed using Parsnp fallback"
            # Generate report and exit
            python "$SCRIPT_DIR/scripts/utils.py" report \
                --roary "$ROARY_OUTPUT" \
                --tree "$OUTPUT_DIR/trees/${PREFIX}_tree.nwk" \
                --output "$OUTPUT_DIR/reports/summary.html"
            echo ""
            echo "========================================="
            echo "  PIPELINE COMPLETED (with Parsnp fallback)"
            echo "========================================="
            echo "End time: $(date)"
            echo "Results available in: $OUTPUT_DIR"
            echo "Tree file: $OUTPUT_DIR/trees/${PREFIX}_tree.nwk"
            echo "Summary report: $OUTPUT_DIR/reports/summary.html"
            exit 0
        else
            print_error "All methods failed. Genomes may be too diverse."
            print_error "Consider using more closely related strains."
            exit 1
        fi
    fi
fi

print_status "✓ Roary completed successfully"

# Step 4: Generate core genome alignment
print_status "Step 4: Generating core genome alignment..."
python "$SCRIPT_DIR/scripts/core_alignment.py" \
    --roary "$ROARY_OUTPUT" \
    --output "$OUTPUT_DIR/core_alignment" \
    --prefix "$PREFIX" || {
        print_warning "Core alignment generation had issues, but continuing..."
    }

# Verify core alignment
FINAL_ALN="$OUTPUT_DIR/core_alignment/${PREFIX}_core_alignment.fasta"
if ! check_core_alignment "$FINAL_ALN"; then
    print_warning "Core alignment is empty or invalid"
    
    # Try to use pan-genome alignment if available
    PAN_ALN="$ROARY_OUTPUT/pan_genome_alignment.aln"
    if [ -f "$PAN_ALN" ] && [ $(stat -c%s "$PAN_ALN" 2>/dev/null || stat -f%z "$PAN_ALN" 2>/dev/null) -gt 100 ]; then
        print_status "Using pan-genome alignment instead"
        cp "$PAN_ALN" "$FINAL_ALN"
    else
        print_error "No valid alignment found. Cannot build tree."
        exit 1
    fi
fi

# Print alignment statistics
ALN_LEN=$(awk '!/^>/ {sum+=length($0)} END {print sum/NR}' "$FINAL_ALN" 2>/dev/null || echo "0")
ALN_SEQS=$(grep -c "^>" "$FINAL_ALN" 2>/dev/null || echo "0")
print_status "Alignment statistics: $ALN_SEQS sequences, ${ALN_LEN%.*} bp"

# Step 5: Build phylogenetic tree
print_status "Step 5: Building phylogenetic tree with $TREE_METHOD..."

# Check if we have a valid alignment for tree building
if [ "${ALN_LEN%.*}" -lt 10 ] || [ "$ALN_SEQS" -lt 2 ]; then
    print_error "Alignment too small for tree building"
    exit 1
fi

python "$SCRIPT_DIR/scripts/build_tree.py" \
    --alignment "$FINAL_ALN" \
    --output "$OUTPUT_DIR/trees" \
    --method "$TREE_METHOD" \
    --threads "$THREADS" \
    --prefix "$PREFIX" || {
        print_error "Tree building failed"
        exit 1
    }

# Verify tree was created
TREE_FILE="$OUTPUT_DIR/trees/${PREFIX}_tree.nwk"
if [ ! -f "$TREE_FILE" ]; then
    print_error "Tree file not created"
    exit 1
fi

print_status "✓ Tree built successfully: $TREE_FILE"

# Step 6: Generate summary report
print_status "Step 6: Generating summary report..."
python "$SCRIPT_DIR/scripts/utils.py" report \
    --roary "$ROARY_OUTPUT" \
    --tree "$TREE_FILE" \
    --output "$OUTPUT_DIR/reports/summary.html" || {
        print_warning "Report generation had issues, but pipeline completed"
    }

# Final summary
echo ""
echo "========================================="
echo "  PIPELINE COMPLETED SUCCESSFULLY"
echo "========================================="
echo "End time: $(date)"
echo ""
echo "📊 RESULTS SUMMARY:"
echo "   ✓ Genomes annotated: $GFF_COUNT"
echo "   ✓ Core genome alignment: ${ALN_SEQS} sequences, ${ALN_LEN%.*} bp"
echo "   ✓ Phylogenetic tree: $(basename "$TREE_FILE")"
echo ""
echo "📁 Output directory: $OUTPUT_DIR"
echo "🌳 Tree file: $TREE_FILE"
echo "📄 Report: $OUTPUT_DIR/reports/summary.html"
echo "📝 Log file: $LOG_FILE"
echo ""
echo "Quick view commands:"
echo "  cat $TREE_FILE"
echo "  python -c \"from Bio import Phylo; Phylo.draw_ascii(open('$TREE_FILE').read())\""
echo ""
echo "========================================="

# Optional: Create a symlink to the latest results
ln -sfn "$OUTPUT_DIR" latest_results
print_status "Created symlink 'latest_results' pointing to this run"

exit 0
