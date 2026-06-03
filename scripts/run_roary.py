#!/usr/bin/env python3
"""
Roary pan-genome analysis runner
"""

import os
import sys
import subprocess
import argparse
from pathlib import Path
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def main():
    parser = argparse.ArgumentParser(description="Run Roary pan-genome analysis")
    parser.add_argument("-i", "--input", required=True, help="Directory with Prokka GFF files")
    parser.add_argument("-o", "--output", required=True, help="Output directory for Roary")
    parser.add_argument("-t", "--threads", type=int, default=4, help="Number of threads")
    args = parser.parse_args()
    
    input_dir = Path(args.input)
    output_dir = Path(args.output)
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Find GFF list
    gff_list = input_dir / "gff_list.txt"
    if not gff_list.exists():
        # Create GFF list if it doesn't exist
        gff_files = []
        for gff_file in input_dir.rglob("*.gff"):
            gff_files.append(gff_file)
        
        with open(gff_list, "w") as f:
            for gf in gff_files:
                f.write(f"{gf}\n")
    
    # Count GFF files
    with open(gff_list) as f:
        n_genomes = len(f.readlines())
    
    logger.info(f"Running Roary on {n_genomes} genomes")
    
    # Roary command
    cmd = [
        "roary",
        "-f", str(output_dir),
        "-p", str(args.threads),
        "-e",  # Create multiFASTA alignments
        "-v",  # Verbose
        "-s",  # Split paralogs
        "--mafft",  # Use MAFFT for alignments
        "--cd", "100",  # Core definition: 100% of isolates
        "-g", "100",  # Core percentage
        "-i", "80",   # Minimum percentage identity for BLAST
        str(gff_list)
    ]
    
    try:
        logger.info("Running Roary (this may take a while)...")
        subprocess.run(cmd, check=True, capture_output=True, text=True)
        logger.info("Roary analysis completed successfully")
        
        # Check for core genome
        core_file = output_dir / "core_gene_alignment.aln"
        if core_file.exists():
            logger.info(f"Core genome alignment created: {core_file}")
        else:
            logger.warning("Core genome alignment not found")
            
    except subprocess.CalledProcessError as e:
        logger.error(f"Roary failed: {e.stderr}")
        sys.exit(1)

if __name__ == "__main__":
    main()
