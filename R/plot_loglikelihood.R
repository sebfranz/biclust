#!/usr/bin/Rscript

library(tidyverse)
library(aricode)  # To calculate rand index
library(ggplot2)  # To plot things #TODO: What things?
library(ggalluvial)  # To plot thingsv #TODO: What things?
library(reshape2)
library(ggfortify)  # For pca-plot


# Scatter-plot the log-liklihood on each axis, color with true allocation
# If more than 2 dim make pca plot
scatter_plot_loglikelihood <- function(dat,
                                       likelihood,
                                       n_cell_clusters,
                                       penalization_lambda,
                                       output_path,
                                       i_main) {
  true_cell_cluster_allocation_vector <- paste("Cluster", pull(dat, var = 'true_cell_cluster_allocation'))  # These needs to be strings for discrete labels in pca plot
  colnames(likelihood) <- paste("Likelihood cell cluster", seq_len(n_cell_clusters))
  likelihood_tibble <- tibble::as_tibble(likelihood)
  data_for_plotting <- tibble::tibble(likelihood_tibble, true_cell_cluster_allocation = true_cell_cluster_allocation_vector)

  filename_plot <- paste0("Decision_line_lambda_", round(penalization_lambda, digits = 3), "_iteration_", i_main, ".png")
  if (ncol(likelihood) == 2) {
    p <- ggplot2::ggplot(data = data_for_plotting, ggplot2::aes(x = "Likelihood cell cluster 1", y = "Likelihood cell cluster 2", color = true_cell_cluster_allocation)) +
      ggplot2::geom_point() +
      ggplot2::geom_abline(intercept = 0, slope = 1) +
      ggplot2::labs(x = "Log-likelihood for fitting into cluster 1", y = "Log-likelihood for fitting into cluster 2")
    png(file.path(output_path, filename_plot))
    p + ggplot2::labs(color = "True cell cluster")
    dev.off()
  } else {
    pca_res <- prcomp(data_for_plotting[, seq_len(ncol(data_for_plotting) - 1)], scale. = TRUE)
    p <- ggplot2::autoplot(pca_res, data = data_for_plotting, colour = 'true_cell_cluster_allocation')
    png(file.path(output_path, filename_plot))
    plot(p)
    dev.off()
  }
}


# Make histograms
hist_plot_loglikelihood <- function(dat,
                                    likelihood,
                                    n_cell_clusters,
                                    penalization_lambda,
                                    output_path,
                                    i_main) {
  true_cell_cluster_allocation_vector <- pull(dat, var = 'true_cell_cluster_allocation')
  colnames(likelihood) <- paste("Likelihood cell cluster", seq_len(n_cell_clusters))
  likelihood_tibble <- tibble::as_tibble(likelihood)

  likelihood_tibble['cell_id'] <- seq_len(nrow(likelihood_tibble))
  plots <- vector(mode = "list", length = n_cell_clusters)
  for (cell_cluster in seq_len(n_cell_clusters)) {
    cell_cluster_rows <- which(true_cell_cluster_allocation_vector == cell_cluster)

    cell_cluster_likelihood <- likelihood_tibble[cell_cluster_rows,]
    # data_for_plotting <- tibble::tibble(cell_cluster_likelihood, true_cell_cluster_allocation = true_cell_cluster_allocation_vector)
    cell_cluster_likelihood <- reshape2::melt(cell_cluster_likelihood, id.vars = "cell_id")

    # Interleaved histograms
    plots[[cell_cluster]] <- ggplot2::ggplot(cell_cluster_likelihood, ggplot2::aes(x = value, color = variable)) +
      ggplot2::geom_histogram(fill = "white", position = "dodge", bins = 100) +
      ggplot2::theme(legend.position = "top") +
      ggplot2::ggtitle(label = paste("True cell cluster", cell_cluster)) +
      ggplot2::coord_trans(x = "log2")
  }
  title <- cowplot::ggdraw() + cowplot::draw_label("Likelihoods for the cells belonging in each true cell cluster.", fontface = 'bold')
  p <- cowplot::plot_grid(
    plotlist = plots,
    align = "hv"
  )
  p <- cowplot::plot_grid(title, p, ncol = 1, rel_heights = c(0.1, 1)) # rel_heights values control title margins
  filename_plot <- paste0("Histograms_lambda_", round(penalization_lambda, digits = 3), "_iteration_", i_main, ".png")
  png(file.path(output_path, filename_plot), width = 1024, height = 800)
  plot(p)
  dev.off()
}