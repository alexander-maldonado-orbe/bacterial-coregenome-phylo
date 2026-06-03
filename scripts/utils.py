#!/usr/bin/env python3
"""
Utility functions for the phylogeny pipeline
"""

import os
import sys
import glob
from pathlib import Path
import argparse
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def check_inputs(input_dir):
    """Validate input genome files"""
    input_path = Path(input_dir)
    
    if not input_path.exists():
        logger.error(f"Input directory {input_dir} does not exist")
        return False
    
    # Check for genome files
    genome_files = []
    for ext in ["*.fa", "*.fasta", "*.fna", "*.faa"]:
        genome_files.extend(input_path.glob(ext))
    
    if len(genome_files) == 0:
        logger.error(f"No FASTA files found in {input_dir}")
        return False
    
    if len(genome_files) < 2:
        logger.error("Need at least 2 genomes for phylogenetic analysis")
        return False
    
    logger.info(f"Found {len(genome_files)} genome files")
    
    # Check file sizes
    for gf in genome_files:
        size = gf.stat().st_size / 1024 / 1024  # Size in MB
        if size < 0.1:
            logger.warning(f"Small file: {gf.name} ({size:.2f} MB)")
    
    return True

def generate_report(roary_dir, tree_file, output_file):
    """Generate HTML summary report"""
    import pandas as pd
    from datetime import datetime
    
    roary_path = Path(roary_dir)
    tree_path = Path(tree_file)
    
    # Collect statistics
    stats = {}
    stats["Analysis date"] = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    # Pan-genome stats
    if (roary_path / "number_of_genes_in_pan_genome.Rtab").exists():
        pan_df = pd.read_csv(roary_path / "number_of_genes_in_pan_genome.Rtab", sep="\t")
        stats["Total genes in pan-genome"] = len(pan_df)
    
    if (roary_path / "core_gene_alignment.aln").exists():
        from Bio import SeqIO
        aln = SeqIO.parse(roary_path / "core_gene_alignment.aln", "fasta")
        core_genes = sum(1 for _ in aln)
        stats["Core genes"] = core_genes
    
    # Create HTML
    html = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <title>Bacterial Phylogeny Pipeline Report</title>
        <style>
            body {{ font-family: Arial, sans-serif; margin: 40px; }}
            h1 {{ color: #2c3e50; }}
            table {{ border-collapse: collapse; width: 50%; margin: 20px 0; }}
            th, td {{ border: 1px solid #ddd; padding: 8px; text-align: left; }}
            th {{ background-color: #4CAF50; color: white; }}
            tr:nth-child(even) {{ background-color: #f2f2f2; }}
        </style>
    </head>
    <body>
        <h1>Bacterial Core Genome Phylogeny Pipeline Report</h1>
        
        <h2>Analysis Parameters</h2>
        <table>
    """
    
    for key, value in stats.items():
        html += f"<tr><th>{key}</th><td>{value}</td></tr>\n"
    
    html += f"""
        </table>
        
        <h2>Output Files</h2>
        <ul>
            <li><strong>Tree file:</strong> {tree_path.name}</li>
            <li><strong>Roary output:</strong> {roary_path}</li>
        </ul>
        
        <h2>Pipeline Status</h2>
        <p>✅ Pipeline completed successfully on {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
        
        <h2>Next Steps</h2>
        <ul>
            <li>Visualize the tree using software like FigTree or iTOL</li>
            <li>Incorporate metadata for advanced analysis</li>
            <li>Perform ancestral state reconstruction (if applicable)</li>
        </ul>
    </body>
    </html>
    """
    
    with open(output_file, "w") as f:
        f.write(html)
    
    logger.info(f"Report generated: {output_file}")
    return True

def main():
    parser = argparse.ArgumentParser(description="Utility functions")
    subparsers = parser.add_subparsers(dest="command", required=True)
    
    # Check inputs command
    check_parser = subparsers.add_parser("check_inputs")
    check_parser.add_argument("input_dir")
    
    # Report command
    report_parser = subparsers.add_parser("report")
    report_parser.add_argument("--roary", required=True)
    report_parser.add_argument("--tree", required=True)
    report_parser.add_argument("--output", required=True)
    
    args = parser.parse_args()
    
    if args.command == "check_inputs":
        sys.exit(0 if check_inputs(args.input_dir) else 1)
    elif args.command == "report":
        generate_report(args.roary, args.tree, args.output)

if __name__ == "__main__":
    main()

