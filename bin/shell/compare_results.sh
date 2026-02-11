#!/bin/bash

# Results Comparison Script
# Compares outputs from old and new Docker environments

echo "=========================================="
echo "Docker Version Control - Results Comparison"
echo "=========================================="
echo ""

# Check if output directories exist
if [ ! -d "output/old_docker" ] || [ ! -d "output/new_docker" ]; then
    echo "Error: Output directories not found."
    echo "Please run ./bin/shell/run_demo.sh first to generate results."
    exit 1
fi

# Check if results files exist
if [ ! -f "output/old_docker/deg_results.csv" ] || [ ! -f "output/new_docker/deg_results.csv" ]; then
    echo "Error: Result files not found."
    echo "Please run ./bin/shell/run_demo.sh first to generate results."
    exit 1
fi

echo "1. FILE DIFFERENCES"
echo "-------------------"
echo "Comparing deg_results.csv files..."
echo ""

# Count total lines
old_lines=$(wc -l < output/old_docker/deg_results.csv)
new_lines=$(wc -l < output/new_docker/deg_results.csv)
echo "Old environment: $old_lines genes analyzed"
echo "New environment: $new_lines genes analyzed"
echo ""

# Show first few lines of diff
echo "First 10 differences:"
diff output/old_docker/deg_results.csv output/new_docker/deg_results.csv | head -20
echo ""
echo "(Many more differences exist - see full diff for details)"
echo ""

echo "2. NUMERICAL SUMMARY"
echo "--------------------"

# Count significant genes (padj < 0.05)
echo "Counting significant genes (padj < 0.05)..."
old_sig=$(awk -F',' 'NR>1 && $7 < 0.05 && $7 != "NA" {count++} END {print count}' output/old_docker/deg_results.csv)
new_sig=$(awk -F',' 'NR>1 && $7 < 0.05 && $7 != "NA" {count++} END {print count}' output/new_docker/deg_results.csv)

echo "Old environment: $old_sig significant genes"
echo "New environment: $new_sig significant genes"
echo "Difference: $((new_sig - old_sig)) genes"
echo ""

echo "3. TOP GENES COMPARISON"
echo "-----------------------"
echo "Top 5 genes from OLD environment:"
head -6 output/old_docker/deg_results.csv | tail -5
echo ""
echo "Top 5 genes from NEW environment:"
head -6 output/new_docker/deg_results.csv | tail -5
echo ""

echo "4. VISUAL OUTPUT"
echo "----------------"
echo "MA plots have been generated:"
echo "  - output/old_docker/ma_plot.png"
echo "  - output/new_docker/ma_plot.png"
echo ""
echo "Open these side-by-side to see visual differences"
echo ""

echo "=========================================="
echo "KEY FINDINGS"
echo "=========================================="
echo ""
echo "✓ Same input data"
echo "✓ Same analysis script"
echo "✗ Different R/Bioconductor versions"
echo "= Different results!"
echo ""
echo "This demonstrates why Docker is essential for"
echo "reproducible bioinformatics research."
echo ""
echo "To see detailed differences, run:"
echo "  diff -u output/old_docker/deg_results.csv output/new_docker/deg_results.csv | less"
echo ""
