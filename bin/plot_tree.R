#!/usr/bin/env Rscript
# plot_tree.R - Visualización del árbol filogenético

# Cargar librerías
suppressPackageStartupMessages({
    library(ape)
    library(ggtree)
    library(ggplot2)
})

# Argumentos de línea de comandos
args <- commandArgs(trailingOnly = TRUE)

if (length(args) < 1) {
    stop("Uso: Rscript bin/plot_tree.R <archivo.treefile> [título] [archivo_salida.pdf]")
}

tree_file <- args[1]
title <- ifelse(length(args) >= 2, args[2], "Filogenia Bacteriana - Core Genome")
output_pdf <- ifelse(length(args) >= 3, args[3], "phylogenetic_tree.pdf")

# Leer árbol
cat("Leyendo árbol:", tree_file, "\n")
tree <- tryCatch({
    read.tree(tree_file)
}, error = function(e) {
    stop("Error al leer el árbol: ", e$message)
})

cat("Número de taxones:", length(tree$tip.label), "\n")

# Crear visualización
p <- ggtree(tree, layout = "circular", branch.length = "rate") +
    geom_tiplab2(size = 2, offset = 0.5) +
    theme_tree2() +
    labs(title = title, 
         subtitle = paste(length(tree$tip.label), "genomas"),
         caption = "Basado en core-genome alignment | IQ-TREE")

# Guardar
ggsave(output_pdf, p, width = 12, height = 12, dpi = 300)
cat("✅ Árbol guardado en:", output_pdf, "\n")

# También guardar versión lineal
p_linear <- ggtree(tree) +
    geom_tiplab(size = 2) +
    theme_tree2() +
    labs(title = title)

output_linear <- gsub(".pdf", "_linear.pdf", output_pdf)
ggsave(output_linear, p_linear, width = 10, height = max(8, length(tree$tip.label) * 0.2), 
       limitsize = FALSE, dpi = 300)
cat("✅ Versión lineal guardada en:", output_linear, "\n")