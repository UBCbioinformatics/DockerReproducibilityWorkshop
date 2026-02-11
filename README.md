# Docker for Version Control: A DEG Analysis Demonstration

## Overview

This project demonstrates the critical importance of Docker for **computational reproducibility** and **version control** in bioinformatics pipelines. It shows how the same analysis script can produce different results (or fail entirely) when run in environments with different R and Bioconductor versions.

## The Problem: Version Dependency in Bioinformatics

Bioinformatics analyses are notoriously sensitive to software versions. A script that works perfectly today might:
- Fail to run in 6 months due to package updates
- Produce different results due to algorithm improvements or bug fixes
- Break due to API changes in dependencies

**This is exactly what Docker solves.**

## What This Demo Shows

We run the **same DEG (Differential Gene Expression) analysis script** in two different Docker containers:

### Container 1: OLD Environment ❌
- **R version:** 3.6.3
- **edgeR version** 3.28.1

### Container 2: NEW Environment ✅
- **R version:** 4.3.2
- **edgeR version** 4.0.16

### Expected behavour:
- How DEGs are defined between the two versions are different, therefore we expect to see different results between these two files, even if the same code is ran

## Project Structure

```
.
├── dockerfiles/             # Docker environment definitions
│   ├── Dockerfile.old       # Older R 3.6.3+ Bioconductor 3.12
│   ├── Dockerfile.new       # Newer R 4.3.2 + Bioconductor 3.18
│   └── Dockerfile.rstudio   # RStudio Server with R 4.3.2 + Bioc 3.18
├── bin/                     # Scripts and executables
│   ├── R/
│   │   └── deg_analysis.R   # DEG analysis script (same for both)
│   └── shell/
│       ├── run_demo.sh      # Automated demo script
│       └── compare_results.sh # Results comparison script
├── inputs/                  # Input data files
│   ├── count_data.csv       # Sample gene expression counts
│   └── sample_info.csv      # Sample metadata
├── output/                  # Analysis outputs 
│   ├── old_docker/          # Results from old environment
│   └── new_docker/          # Results from new environment
├── docker-compose.yml       # Orchestrate all containers
├── README.md                # This file
├── DOCKER_REFERENCE.md      # Docker command reference

```

## Prerequisites

- Docker installed ([Get Docker](https://docs.docker.com/get-docker/))
- Docker Compose (usually included with Docker Desktop)
- ~2GB free disk space for images
- 5-10 minutes for initial build

# Docker DEG Analysis Cheatsheet

## Using Dockerfile.old:

### Use Dockerfile.old from Dockerhub:

```bash
docker pull sleung124/docker-workshop-deg-old
docker tag sleung124/docker-workshop-deg-old docker-workshop-deg-old
```

### Mac/Linux Terminal

```bash
docker run --rm -v $(pwd)/output/old_docker:/analysis/output -v $(pwd)/inputs:/analysis/inputs -v $(pwd)/bin/R:/analysis/bin/R docker-workshop-deg-old sh -c "Rscript bin/R/deg_analysis.R && cp deg_results.csv ma_plot.png /analysis/output/ 2>/dev/null || true"
```

### PowerShell

```powershell
docker run --rm -v ${PWD}/output/old_docker:/analysis/output -v ${PWD}/inputs:/analysis/inputs -v ${PWD}/bin/R:/analysis/bin/R docker-workshop-deg-old sh -c "Rscript bin/R/deg_analysis.R && cp deg_results.csv ma_plot.png /analysis/output/ 2>/dev/null || true"
```

### RStudio Terminal (Git Bash / MINGW64)

```bash
MSYS_NO_PATHCONV=1 docker run --rm \
  -v "$(pwd -W)/output/old_docker:/analysis/output" \
  -v "$(pwd -W)/inputs:/analysis/inputs" \
  -v "$(pwd -W)/bin/R:/analysis/bin/R" \
  docker-workshop-deg-old \
  sh -c "Rscript bin/R/deg_analysis.R && cp deg_results.csv ma_plot.png /analysis/output/ 2>/dev/null || true"
```


## Using Dockerfile.new

### Use Dockerfile.new from Dockerhub:

```bash
docker pull sleung124/docker-workshop-deg-new
docker tag sleung124/docker-workshop-deg-new docker-workshop-deg-new
```

### Mac/Linux Terminal

```bash
docker run --rm -v $(pwd)/output/new_docker:/analysis/output -v $(pwd)/inputs:/analysis/inputs -v $(pwd)/bin/R:/analysis/bin/R docker-workshop-deg-new sh -c "Rscript bin/R/deg_analysis.R && cp deg_results.csv ma_plot.png /analysis/output/ 2>/dev/null || true"
```

### PowerShell

```powershell
docker run --rm -v ${PWD}/output/new_docker:/analysis/output -v ${PWD}/inputs:/analysis/inputs -v ${PWD}/bin/R:/analysis/bin/R docker-workshop-deg-new sh -c "Rscript bin/R/deg_analysis.R && cp deg_results.csv ma_plot.png /analysis/output/ 2>/dev/null || true"
```

### RStudio Terminal (Git Bash / MINGW64)

```bash
MSYS_NO_PATHCONV=1 docker run --rm \
  -v "$(pwd -W)/output/new_docker:/analysis/output" \
  -v "$(pwd -W)/inputs:/analysis/inputs" \
  -v "$(pwd -W)/bin/R:/analysis/bin/R" \
  docker-workshop-deg-new \
  sh -c "Rscript bin/R/deg_analysis.R && cp deg_results.csv ma_plot.png /analysis/output/ 2>/dev/null || true"
```

## Starting RStudio instance

### Use Dockerfile.rstudio from Dockerhub:

```bash
docker pull sleung124/docker-workshop-deg-rstudio
docker tag sleung124/docker-workshop-deg-rstudio docker-workshop-deg-rstudio
```

### RStudio Terminal (Git Bash / MINGW64)

```bash
docker run --rm -p 8787:8787 -v ${PWD}:/home/rstudio/analysis -v ${PWD}/output/rstudio:/home/rstudio/analysis/output -e PASSWORD=demo --name docker-workshop-rstudio docker-workshop-rstudio
```

### Automated Demo Script 

```bash
chmod +x bin/shell/run_demo.sh
./bin/shell/run_demo.sh
```

This will:
1. Build both Docker images
2. Run the analysis in both environments
3. Save results to `output/old_docker/` and `output/new_docker/`
4. Display version information for comparison
