#!/usr/bin/env python3
"""
Build phylogenetic tree from core genome alignment
"""

import os
import sys
import subprocess
import argparse
from pathlib import Path
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def build_tree_iqtree(alignment, output_dir, threads, prefix):
    """Build tree using IQ-TREE"""
    output_prefix = output_dir / prefix
    cmd = [
        "iqtree2",
        "-s", str(alignment),
        "-m", "MFP",  # ModelFinder Plus
        "-T", str(threads),
        "-B", "1000",  # 1000 ultrafast bootstrap replicates
        "--prefix", str(output_prefix),
        "--seed", "12345"
    ]
    
    logger.info(f"Running IQ-TREE with {threads} threads...")
    try:
        subprocess.run(cmd, check=True, capture_output=True, text=True)
        
        # Rename tree file
        tree_file = output_prefix + ".treefile"
        final_tree = output_dir / f"{prefix}_tree.nwk"
        if Path(tree_file).exists():
            import shutil
            shutil.copy(tree_file, final_tree)
            logger.info(f"Tree saved to {final_tree}")
            return final_tree
        else:
            logger.error("IQ-TREE did not produce expected output")
            return None
    except subprocess.CalledProcessError as e:
        logger.error(f"IQ-TREE failed: {e.stderr}")
        return None

def build_tree_fasttree(alignment, output_dir, threads, prefix):
    """Build tree using FastTree"""
    tree_file = output_dir / f"{prefix}_tree.nwk"
    cmd = [
        "FastTreeMP",
        "-nt",  # Nucleotide alignment
        "-gtr",  # GTR model
        "-gamma",  # Gamma-distributed rates
        "-boot", "1000",  # 1000 bootstrap replicates
        "-threads", str(threads),
        str(alignment)
    ]
    
    logger.info(f"Running FastTree with {threads} threads...")
    try:
        with open(tree_file, "w") as f:
            subprocess.run(cmd, check=True, stdout=f, stderr=subprocess.PIPE, text=True)
        logger.info(f"Tree saved to {tree_file}")
        return tree_file
    except subprocess.CalledProcessError as e:
        logger.error(f"FastTree failed: {e.stderr}")
        return None

def visualize_tree(tree_file, output_dir, prefix):
    """Create basic tree visualization using Python"""
    try:
        import matplotlib.pyplot as plt
        from Bio import Phylo
        
        tree = Phylo.read(tree_file, "newick")
        fig = plt.figure(figsize=(12, 8))
        ax = fig.add_subplot(1, 1, 1)
        Phylo.draw(tree, axes=ax, do_show=False)
        plt.title(f"Phylogenetic Tree - {prefix}")
        plt.tight_layout()
        
        viz_file = output_dir / f"{prefix}_tree.png"
        plt.savefig(viz_file, dpi=300)
        logger.info(f"Tree visualization saved to {viz_file}")
    except Exception as e:
        logger.warning(f"Could not create visualization: {e}")

def main():
    parser = argparse.ArgumentParser(description="Build phylogenetic tree")
    parser.add_argument("-a", "--alignment", required=True, help="Core genome alignment file")
    parser.add_argument("-o", "--output", required=True, help="Output directory")
    parser.add_argument("-m", "--method", choices=["iqtree", "fasttree"], default="iqtree", help="Tree building method")
    parser.add_argument("-t", "--threads", type=int, default=4, help="Number of threads")
    parser.add_argument("-p", "--prefix", default="core_genome", help="Output prefix")
    args = parser.parse_args()
    
    alignment = Path(args.alignment)
    if not alignment.exists():
        logger.error(f"Alignment file not found: {alignment}")
        sys.exit(1)
    
    output_dir = Path(args.output)
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Build tree
    if args.method == "iqtree":
        tree_file = build_tree_iqtree(alignment, output_dir, args.threads, args.prefix)
    else:
        tree_file = build_tree_fasttree(alignment, output_dir, args.threads, args.prefix)
    
    if tree_file and tree_file.exists():
        logger.info(f"Tree building completed successfully")
        visualize_tree(tree_file, output_dir, args.prefix)
    else:
        logger.error("Tree building failed")
        sys.exit(1)

if __name__ == "__main__":
    main()
