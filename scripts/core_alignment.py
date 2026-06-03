#!/usr/bin/env python3
"""
Generate core genome alignment from Roary output
"""

import os
import sys
from pathlib import Path
import argparse
import subprocess
from Bio import SeqIO
from Bio.Align import MultipleSeqAlignment
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def extract_core_genes(roary_dir, output_file):
    """Extract and concatenate core gene alignments"""
    roary_dir = Path(roary_dir)
    core_alignments = list(roary_dir.glob("core_gene_alignment.*"))
    
    if not core_alignments:
        # Try alternative location
        core_alignments = list(roary_dir.glob("pan_genome_reference.fa"))
    
    if not core_alignments:
        logger.error("No core genome alignment found in Roary output")
        return False
    
    # Use the alignment directly if it's already concatenated
    main_aln = roary_dir / "core_gene_alignment.aln"
    if main_aln.exists():
        logger.info(f"Using existing core alignment: {main_aln}")
        import shutil
        shutil.copy(main_aln, output_file)
        return True
    
    # Otherwise, concatenate individual gene alignments
    gene_files = sorted(roary_dir.glob("core_genes/*.fa")) or sorted(roary_dir.glob("*aln"))
    
    if not gene_files:
        logger.error("No individual gene alignments found")
        return False
    
    logger.info(f"Concatenating {len(gene_files)} core gene alignments")
    
    # Read all alignments
    all_seqs = {}
    for gene_file in gene_files:
        for record in SeqIO.parse(gene_file, "fasta"):
            if record.id not in all_seqs:
                all_seqs[record.id] = []
            all_seqs[record.id].append(str(record.seq))
    
    # Write concatenated alignment
    with open(output_file, "w") as f:
        for seq_id, seqs in all_seqs.items():
            concatenated = "".join(seqs)
            f.write(f">{seq_id}\n{concatenated}\n")
    
    logger.info(f"Core genome alignment written to {output_file}")
    return True

def trim_alignment(input_file, output_file):
    """Trim alignment using trimal"""
    try:
        cmd = ["trimal", "-in", input_file, "-out", output_file, "-automated1"]
        subprocess.run(cmd, check=True, capture_output=True)
        logger.info(f"Alignment trimmed: {output_file}")
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        logger.warning("Trimming failed or trimal not available, using untrimmed alignment")
        import shutil
        shutil.copy(input_file, output_file)
        return False

def main():
    parser = argparse.ArgumentParser(description="Process core genome alignment")
    parser.add_argument("-r", "--roary", required=True, help="Roary output directory")
    parser.add_argument("-o", "--output", required=True, help="Output directory")
    parser.add_argument("-p", "--prefix", default="core_genome", help="Output prefix")
    args = parser.parse_args()
    
    roary_dir = Path(args.roary)
    output_dir = Path(args.output)
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Extract core alignment
    raw_alignment = output_dir / f"{args.prefix}_core_alignment_raw.fasta"
    if not extract_core_genes(roary_dir, raw_alignment):
        logger.error("Failed to extract core genome alignment")
        sys.exit(1)
    
    # Trim alignment
    final_alignment = output_dir / f"{args.prefix}_core_alignment.fasta"
    trim_alignment(raw_alignment, final_alignment)
    
    # Generate alignment statistics
    n_seqs = 0
    seq_lengths = []
    for record in SeqIO.parse(final_alignment, "fasta"):
        n_seqs += 1
        seq_lengths.append(len(record.seq))
    
    logger.info(f"Alignment statistics:")
    logger.info(f"  Number of sequences: {n_seqs}")
    logger.info(f"  Alignment length: {sum(seq_lengths)/len(seq_lengths):.0f} bp")
    logger.info(f"  Length range: {min(seq_lengths)} - {max(seq_lengths)} bp")

if __name__ == "__main__":
    main()
