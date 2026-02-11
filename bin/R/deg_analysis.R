#!/usr/bin/env Rscript

# Differential Expression Analysis with edgeR
# This script demonstrates version-dependent behavior in edgeR:
# - OLD edgeR (~3.28): Uses classic exactTest with basic BCV estimation
# - NEW edgeR (~4.0+): Uses quasi-likelihood (QL) F-test with robust methods
# These methods produce DRAMATICALLY different results!

cat("=================================================================\n")
cat("===      DIFFERENTIAL EXPRESSION ANALYSIS WITH EDGER          ===\n")
cat("=================================================================\n\n")
cat(paste("R version:", R.version.string, "\n"))

# Load required packages
suppressPackageStartupMessages({
  library(edgeR)
})

cat(paste("edgeR version:", packageVersion("edgeR"), "\n"))
cat(paste("Date:", Sys.Date(), "\n"))
cat("\n=================================================================\n\n")

# Load the count data
cat("Loading count data...\n")
counts <- read.csv("inputs/count_data.csv", row.names = 1)
sample_info <- read.csv("inputs/sample_info.csv", row.names = 1)

cat(paste("  Samples:", nrow(sample_info), "\n"))
cat(paste("  Genes:", nrow(counts), "\n\n"))

# Create DGEList object
cat("Creating DGEList object...\n")
group <- factor(sample_info$condition)
dge <- DGEList(counts = counts, group = group)

cat(paste("  Groups:", paste(levels(group), collapse = ", "), "\n"))
cat(paste("  Design: ~", paste(levels(group), collapse = " vs "), "\n\n"))

# Filter low count genes
cat("Filtering low-count genes...\n")
keep <- filterByExpr(dge)
dge <- dge[keep, , keep.lib.sizes = FALSE]
cat(paste("  Genes retained:", sum(keep), "out of", length(keep), "\n\n"))

# Normalize with TMM
cat("Normalizing with TMM method...\n")
dge <- calcNormFactors(dge, method = "TMM")

cat("  Normalization factors:\n")
print(dge$samples$norm.factors)
cat("\n")

# Estimate dispersions
cat("Estimating dispersions...\n")

# Check edgeR version to use appropriate method
edger_version <- packageVersion("edgeR")

if (edger_version >= "3.30.0") {
  # NEW METHOD: Use quasi-likelihood pipeline (more accurate, more stringent)
  cat("  Using QUASI-LIKELIHOOD (QL) pipeline (edgeR >= 3.30)\n")
  cat("  This method is more robust and accurate\n\n")
  
  # Create design matrix
  design <- model.matrix(~group)
  
  # Estimate dispersions with robust method
  dge <- estimateDisp(dge, design, robust = TRUE)
  
  cat(paste("  Common dispersion:", round(dge$common.dispersion, 4), "\n"))
  cat(paste("  Trended dispersion range:", 
            round(min(dge$trended.dispersion), 4), "-", 
            round(max(dge$trended.dispersion), 4), "\n"))
  cat("\n")
  
  # Fit QL model
  cat("Fitting quasi-likelihood model...\n")
  fit <- glmQLFit(dge, design, robust = TRUE)
  
  # Perform QL F-test
  cat("Performing quasi-likelihood F-test...\n")
  qlf <- glmQLFTest(fit, coef = 2)
  results <- topTags(qlf, n = Inf, sort.by = "PValue")$table
  
  cat("  Test: Quasi-likelihood F-test\n")
  
} else {
  # OLD METHOD: Use classic exact test (less accurate, more liberal)
  cat("  Using CLASSIC EXACT TEST pipeline (edgeR < 3.30)\n")
  cat("  This is the older, less robust method\n\n")
  
  # Estimate dispersions with classic method
  dge <- estimateCommonDisp(dge)
  dge <- estimateTagwiseDisp(dge)
  
  cat(paste("  Common dispersion:", round(dge$common.dispersion, 4), "\n"))
  cat(paste("  Tagwise dispersion range:", 
            round(min(dge$tagwise.dispersion), 4), "-", 
            round(max(dge$tagwise.dispersion), 4), "\n"))
  cat("\n")
  
  # Perform exact test
  cat("Performing exact test...\n")
  et <- exactTest(dge)
  results <- topTags(et, n = Inf, sort.by = "PValue")$table
  
  cat("  Test: Exact test (classic)\n")
}

cat("\n")

# Summary
cat("=================================================================\n")
cat("===                    RESULTS SUMMARY                        ===\n")
cat("=================================================================\n\n")

# Count significant genes at different FDR thresholds
sig_001 <- sum(results$FDR < 0.01, na.rm = TRUE)
sig_005 <- sum(results$FDR < 0.05, na.rm = TRUE)
sig_010 <- sum(results$FDR < 0.10, na.rm = TRUE)

up_genes <- sum(results$FDR < 0.05 & results$logFC > 0, na.rm = TRUE)
down_genes <- sum(results$FDR < 0.05 & results$logFC < 0, na.rm = TRUE)

cat("Significant genes at different FDR thresholds:\n")
cat(paste("  FDR < 0.01:", sig_001, "genes\n"))
cat(paste("  FDR < 0.05:", sig_005, "genes\n"))
cat(paste("  FDR < 0.10:", sig_010, "genes\n"))
cat("\n")

cat("Direction of change (FDR < 0.05):\n")
cat(paste("  Upregulated:  ", up_genes, "\n"))
cat(paste("  Downregulated:", down_genes, "\n"))
cat("\n")

# Add gene names as first column
results_with_genes <- cbind(Gene = rownames(results), results)

# Save results
write.csv(results_with_genes, "deg_results.csv", row.names = FALSE)
cat("Results saved to: deg_results.csv\n\n")

# Create MA plot
cat("Generating MA plot...\n")
png("ma_plot.png", width = 800, height = 600)

# Plot with different colors for significant genes
plot(results$logCPM, results$logFC,
     pch = 20, cex = 0.5, col = "gray60",
     xlab = "Average log CPM", ylab = "Log Fold Change",
     main = paste0("MA Plot - edgeR ", packageVersion("edgeR"), "\n",
                   sig_005, " significant genes (FDR < 0.05)"))

# Highlight significant genes
sig_points <- results$FDR < 0.05
points(results$logCPM[sig_points], results$logFC[sig_points],
       pch = 20, cex = 0.5, col = "red")

# Add horizontal line at y=0
abline(h = 0, col = "blue", lty = 2)

# Add legend
legend("topright", 
       legend = c(paste("Significant (FDR < 0.05):", sig_005),
                  paste("Not significant:", sum(!sig_points))),
       col = c("red", "gray60"), pch = 20, cex = 0.8)

dev.off()
cat("MA plot saved to: ma_plot.png\n\n")

# Print top differentially expressed genes
cat("=================================================================\n")
cat("===         TOP 20 DIFFERENTIALLY EXPRESSED GENES             ===\n")
cat("=================================================================\n\n")
top_results <- head(results_with_genes, 20)
print(top_results)

cat("\n=================================================================\n")
cat("===                  ANALYSIS COMPLETE                        ===\n")
cat("=================================================================\n\n")

cat("Method Used:\n")
if (edger_version >= "3.30.0") {
  cat("  QUASI-LIKELIHOOD (QL) F-TEST\n")
  cat("  - More robust dispersion estimation\n")
  cat("  - Better control of false positives\n")
  cat("  - Generally more stringent\n")
} else {
  cat("  CLASSIC EXACT TEST\n")
  cat("  - Traditional edgeR method\n")
  cat("  - Less robust to outliers\n")
  cat("  - Generally more liberal\n")
}
cat("\n")

cat("Environment Info:\n")
cat(paste("  R version:", R.version.string, "\n"))
cat(paste("  edgeR version:", packageVersion("edgeR"), "\n"))
cat(paste("  Analysis method:", 
          ifelse(edger_version >= "3.30.0", "QL F-test", "Exact test"), "\n"))
cat("\n=================================================================\n\n")