#!/usr/bin/env python3
"""
Anotación masiva de genomas bacterianos usando Bakta.
Uso: python bin/run_annotation.py --input data/raw_genomes --output results/annotation
"""

import os
import glob
import argparse
import subprocess
from multiprocessing import Pool, cpu_count

def parse_arguments():
    parser = argparse.ArgumentParser(description='Anotar múltiples genomas con Bakta')
    parser.add_argument('--input', required=True, help='Carpeta con archivos .fasta o .fna')
    parser.add_argument('--output', required=True, help='Carpeta de salida para anotaciones')
    parser.add_argument('--threads', type=int, default=None, help='Número de threads (default: CPU-2)')
    parser.add_argument('--db', default='light', choices=['light', 'full'], help='Base de datos de Bakta')
    return parser.parse_args()

def annotate_genome(args):
    """Anota un solo genoma."""
    fasta_path, output_dir, db_type = args
    sample_name = os.path.basename(fasta_path).replace('.fasta', '').replace('.fna', '').replace('.fa', '')
    output_subdir = os.path.join(output_dir, sample_name)
    
    cmd = f"bakta --db {db_type} --threads 2 --output {output_subdir} --prefix {sample_name} {fasta_path}"
    
    print(f"[Anotando] {sample_name}")
    try:
        subprocess.run(cmd, shell=True, check=True, executable='/bin/bash')
        print(f"[OK] {sample_name}")
        return True
    except subprocess.CalledProcessError as e:
        print(f"[ERROR] {sample_name}: {e}")
        return False

def main():
    args = parse_arguments()
    
    # Buscar todos los genomas
    genomes = glob.glob(f"{args.input}/*.fasta") + glob.glob(f"{args.input}/*.fna") + glob.glob(f"{args.input}/*.fa")
    if not genomes:
        print(f"Error: No se encontraron archivos .fasta/.fna/.fa en {args.input}")
        return
    
    # Configurar threads
    threads = args.threads if args.threads else max(1, cpu_count() - 2)
    os.makedirs(args.output, exist_ok=True)
    
    print(f"Encontrados {len(genomes)} genomas. Usando {threads} CPUs.")
    
    # Preparar argumentos para paralelización
    task_args = [(genome, args.output, args.db) for genome in genomes]
    
    # Ejecutar en paralelo
    with Pool(processes=threads) as pool:
        results = pool.map(annotate_genome, task_args)
    
    success_count = sum(results)
    print(f"\nCompletado: {success_count}/{len(genomes)} genomas anotados correctamente.")
    
    if success_count < len(genomes):
        print("Advertencia: Algunos genomas fallaron. Revisa los mensajes de error.")

if __name__ == "__main__":
    main()