# Makefile for Docker DEG Analysis Demo

.PHONY: all build run clean

# Help message: 
help: 
	@echo "Docker DEG Analysis - Available Commands:"
	@echo "  make all        - Build and run both old and new Docker environments"
	@echo "  make build      - Build Docker images for both environments"		
	@echo "  make run        - Run differential expression analyses in both environments"
	@echo "  make rstudio    - Start RStudio server for interactive analysis"
	@echo "  make clean      - Stop containers and remove output directories"

# Default target - build and run both environments
all: build run

# Build all Docker images
build:
	docker-compose build deg-old deg-new

# Run both analyses
run:
	@mkdir -p output/old_docker output/new_docker
	docker-compose up deg-old deg-new

docker build -t [IMAGE_NAME] -f [DOCKERFILE_PATH] .

# Run OLD environment only
run-old: build-old ## Run analysis with OLD environment (R 3.6.3)
	@mkdir -p output/old_docker
	docker run --rm \
		-v $$(pwd)/output/old_docker:/analysis/output \
		-v $$(pwd)/inputs:/analysis/inputs \
		-v $$(pwd)/bin/R:/analysis/bin/R \
		docker-workshop-deg-old \
		sh -c "Rscript bin/R/deg_analysis.R && cp deg_results.csv ma_plot.png /analysis/output/ 2>/dev/null || true"

# Run NEW environment only
run-new: build-new ## Run analysis with NEW environment (R 4.3.2)
	@mkdir -p output/new_docker
	docker run --rm \
		-v $$(pwd)/output/new_docker:/analysis/output \
		-v $$(pwd)/inputs:/analysis/inputs \
		-v $$(pwd)/bin/R:/analysis/bin/R \
		docker-workshop-deg-new \
		sh -c "Rscript bin/R/deg_analysis.R && cp deg_results.csv ma_plot.png /analysis/output/ 2>/dev/null || true"

# Build and start RStudio
rstudio: ## Start RStudio Server at http://localhost:8787
	@mkdir -p output/rstudio
	docker build -f dockerfiles/Dockerfile.rstudio -t deg-analysis-rstudio .
	docker run -d \
		-p 8787:8787 \
		-v $$(pwd):/home/rstudio/analysis \
		-v $$(pwd)/output/rstudio:/home/rstudio/analysis/output \
		-e PASSWORD=deseq2demo \
		--name deg-analysis-rstudio \
		deg-analysis-rstudio
	@echo "RStudio running at http://localhost:8787 (user: rstudio, password: deseq2demo)"


# Clean up containers and outputs
clean:
	docker-compose down
	rm -rf output/old_docker output/new_docker output/rstudio
