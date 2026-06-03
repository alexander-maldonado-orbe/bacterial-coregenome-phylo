#!/usr/bin/env python3
"""
Prokka annotation runner for multiple genomes
"""

import os
import sys
import subprocess
import argparse
from pathlib import Path
from concurrent.futures import ProcessPoolExecutor, as_completed
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def annotate_genome(genome_file, output_dir, threads=1):
    """Annotate a single genome with Prokka"""
    genome_name = Path(genome_file).stem
    genome_output = Path(output_dir) / genome_name
    
    # Skip if already annotated
    if (genome_output / f"{genome_name}.gff").exists():
        logger.info(f"Skipping {genome_name} - already annotated")
        return genome_name, True
    
    cmd = [
        "prokka",
        "--outdir", str(genome_output),
        "--prefix", genome_name,
        "--cpus", str(threads),
        "--kingdom", "Bacteria",
        "--locustag", genome_name[:8],
        "--compliant",  # Make output GFF3 compliant
        "--force",  # Overwrite existing
        str(genome_file)
    ]
    
    try:
        logger.info(f"Annotating {genome_name}...")
        subprocess.run(cmd, check=True, capture_output=True, text=True)
        return genome_name, True
    except subprocess.CalledProcessError as e:
        logger.error(f"Failed to annotate {genome_name}: {e.stderr}")
        return genome_name, False

def main():
    parser = argparse.ArgumentParser(description="Run Prokka on multiple genomes")
    parser.add_argument("-i", "--input", required=True, help="Input directory with genome FASTA files")
    parser.add_argument("-o", "--output", required=True, help="Output directory for Prokka results")
    parser.add_argument("-t", "--threads", type=int, default=4, help="Total CPU threads")
    args = parser.parse_args()
    
    input_dir = Path(args.input)
    output_dir = Path(args.output)
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Find all FASTA files
    genome_files = []
    for ext in ["*.fa", "*.fasta", "*.fna", "*.faa"]:
        genome_files.extend(input_dir.glob(ext))
    
    if not genome_files:
        logger.error(f"No FASTA files found in {input_dir}")
        sys.exit(1)
    
    logger.info(f"Found {len(genome_files)} genomes to annotate")
    
    # Determine threads per genome (minimum 1, maximum 4)
    threads_per_genome = max(1, min(4, args.threads // len(genome_files) if len(genome_files) > 0 else args.threads))
    
    # Run Prokka in parallel
    results = []
    with ProcessPoolExecutor(max_workers=min(len(genome_files), args.threads)) as executor:
        futures = {
            executor.submit(annotate_genome, gf, output_dir, threads_per_genome): gf
            for gf in genome_files
        }
        
        for future in as_completed(futures):
            name, success = future.result()
            results.append(success)
            logger.info(f"Completed: {name} (Success: {success})")
    
    # Summary
    successful = sum(results)
    logger.info(f"Annotation complete: {successful}/{len(genome_files)} successful")
    
    if successful != len(genome_files):
        logger.warning(f"Failed to annotate {len(genome_files) - successful} genomes")
        sys.exit(1)
    
    # Create list of GFF files for Roary
    gff_list = output_dir / "gff_list.txt"
    with open(gff_list, "w") as f:
        for gf in genome_files:
            genome_name = gf.stem
            gff_file = output_dir / genome_name / f"{genome_name}.gff"
            if gff_file.exists():
                f.write(f"{gff_file}\n")
    
    logger.info(f"GFF file list created: {gff_list}")
    print(f"GFF_LIST={gff_list}")  # For capture by shell script

if __name__ == "__main__":
    main()
