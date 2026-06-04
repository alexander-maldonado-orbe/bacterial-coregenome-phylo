#!/usr/bin/env python3
"""
Roary pan-genome analysis runner with fallback options
"""

import os
import sys
import subprocess
import argparse
from pathlib import Path
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def install_perl_modules():
    """Install missing Perl modules if needed"""
    try:
        subprocess.run(["cpanm", "File::Find::Rule"], capture_output=True)
        logger.info("Perl modules installed")
    except:
        logger.warning("Could not install Perl modules automatically")

def main():
    parser = argparse.ArgumentParser(description="Run Roary pan-genome analysis")
    parser.add_argument("-i", "--input", required=True, help="Directory with Prokka GFF files")
    parser.add_argument("-o", "--output", required=True, help="Output directory for Roary")
    parser.add_argument("-t", "--threads", type=int, default=4, help="Number of threads")
    parser.add_argument("-cd", "--core_percent", type=int, default=50, 
                        help="Core gene percentage (0-100, lower = more tolerant)")
    args = parser.parse_args()
    
    input_dir = Path(args.input)
    output_dir = Path(args.output)
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Find GFF files
    gff_files = list(input_dir.rglob("*.gff"))
    gff_files = [str(f) for f in gff_files if f.stat().st_size > 0]
    
    if len(gff_files) < 2:
        logger.error(f"Need at least 2 GFF files, found {len(gff_files)}")
        sys.exit(1)
    
    logger.info(f"Running Roary on {len(gff_files)} genomes")
    logger.info(f"Core percentage threshold: {args.core_percent}%")
    
    # Check for Perl modules and install if missing
    result = subprocess.run(["perl", "-e", "use File::Find::Rule;"], capture_output=True)
    if result.returncode != 0:
        logger.warning("Missing Perl modules. Attempting to install...")
        install_perl_modules()
    
    # Try multiple strategies to get core alignment
    strategies = [
        # Strategy 1: Standard approach
        {
            "cd": args.core_percent,
            "i": 80,
            "extra": []
        },
        # Strategy 2: More permissive
        {
            "cd": 30,
            "i": 70,
            "extra": []
        },
        # Strategy 3: Most permissive (accessory genes)
        {
            "cd": 0,
            "i": 60,
            "extra": []
        }
    ]
    
    for idx, strategy in enumerate(strategies, 1):
        logger.info(f"Trying strategy {idx} with core={strategy['cd']}%, identity={strategy['i']}%")
        
        cmd = [
            "roary",
            "-f", str(output_dir / f"run_{idx}"),
            "-p", str(args.threads),
            "-e",
            "-v",
            "--mafft",
            "-cd", str(strategy["cd"]),
            "-i", str(strategy["i"]),
        ] + gff_files
        
        try:
            subprocess.run(cmd, check=True, capture_output=True, text=True)
            
            # Check if core alignment was created
            core_file = output_dir / f"run_{idx}" / "core_gene_alignment.aln"
            if core_file.exists() and core_file.stat().st_size > 100:
                logger.info(f"✓ Core alignment found in run_{idx} (size: {core_file.stat().st_size} bytes)")
                # Copy to main output
                import shutil
                shutil.copy(core_file, output_dir / "core_gene_alignment.aln")
                
                # Also copy gene presence matrix
                matrix_file = output_dir / f"run_{idx}" / "gene_presence_absence.csv"
                if matrix_file.exists():
                    shutil.copy(matrix_file, output_dir / "gene_presence_absence.csv")
                
                logger.info("✓ Roary completed successfully")
                return
                
        except subprocess.CalledProcessError as e:
            logger.warning(f"Strategy {idx} failed: {e.stderr[:200]}")
            continue
    
    logger.error("❌ All Roary strategies failed. Genomes may be too diverse.")
    logger.info("Consider using Parsnp or another SNP-based approach for diverse genomes.")
    sys.exit(1)

if __name__ == "__main__":
    main()
