#!/bin/bash

# Docker Version Control Demonstration Script
# This script builds and runs both old and new R environments to show version differences

set -e  # Exit on error

echo "=========================================="
echo "Docker Version Control Demonstration"
echo "DEG Analysis with Different R/Bioconductor Versions"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create output directories
mkdir -p output/old_docker output/new_docker

echo -e "${BLUE}Step 1: Building OLD environment (R 4.0.5, Bioconductor 3.12)${NC}"
echo "This may take a few minutes on first build..."
docker build -f dockerfiles/Dockerfile.old -t deg-analysis:old .

echo ""
echo -e "${BLUE}Step 2: Building NEW environment (R 4.3.2, Bioconductor 3.18)${NC}"
echo "This may take a few minutes on first build..."
docker build -f dockerfiles/Dockerfile.new -t deg-analysis:new .

echo ""
echo "=========================================="
echo -e "${RED}Running analysis with OLD environment${NC}"
echo "=========================================="
docker run --rm -v "$(pwd)/output/old_docker:/analysis/output" \
    deg-analysis:old sh -c "Rscript bin/R/deg_analysis.R && cp deg_results.csv ma_plot.png /analysis/output/ 2>/dev/null || true"

echo ""
echo "=========================================="
echo -e "${GREEN}Running analysis with NEW environment${NC}"
echo "=========================================="
docker run --rm -v "$(pwd)/output/new_docker:/analysis/output" \
    deg-analysis:new sh -c "Rscript bin/R/deg_analysis.R && cp deg_results.csv ma_plot.png /analysis/output/ 2>/dev/null || true"

echo ""
echo "=========================================="
echo "Analysis Complete!"
echo "=========================================="
echo ""
echo "Results have been saved to:"
echo "  - output/old_docker/  (R 4.0.5 + Bioconductor 3.12)"
echo "  - output/new_docker/  (R 4.3.2 + Bioconductor 3.18)"
echo ""
echo "Compare the results to see version differences:"
echo "  diff output/old_docker/deg_results.csv output/new_docker/deg_results.csv"
echo ""
echo "Or view the summary with:"
echo "  head -20 output/old_docker/deg_results.csv"
echo "  head -20 output/new_docker/deg_results.csv"
echo ""
