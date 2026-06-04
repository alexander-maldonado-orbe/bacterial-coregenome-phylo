#!/bin/bash
# Quick test script to verify pipeline installation

echo "=== Testing Bacterial Phylogeny Pipeline ==="
echo ""

# Test 1: Check conda environment
echo "Test 1: Checking conda environment..."
if conda env list | grep -q "bact_phylogeny"; then
    echo "✓ Environment exists"
else
    echo "✗ Environment not found. Run: conda env create -f environment.yml"
    exit 1
fi

# Test 2: Check required tools
echo ""
echo "Test 2: Checking required tools..."
tools=("prokka" "roary" "mafft" "FastTreeMP")
missing=0
for tool in "${tools[@]}"; do
    if command -v $tool &> /dev/null; then
        echo "✓ $tool found"
    else
        echo "✗ $tool missing"
        missing=1
    fi
done

if [ $missing -eq 1 ]; then
    echo "Some tools missing. Run: conda activate bact_phylogeny"
fi

# Test 3: Check Python packages
echo ""
echo "Test 3: Checking Python packages..."
python -c "import Bio, pandas" 2>/dev/null && echo "✓ BioPython and Pandas OK" || echo "✗ Python packages missing"

echo ""
echo "=== Test Complete ==="
echo "If all tests passed, run: ./pipeline.sh -i your_genomes/ -o results/"
