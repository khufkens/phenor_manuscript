# Figure 2.
#
# Arrow plot comparing two model optimizations
# and the difference in model output.
# Mean differences are used across different runs within
# a given model.

# load library
library(phenor)

# read the comparison data in the repository
# [only use the deciduous broadleaf data for the figure]
comparison = readRDS("~/phenor_files/comparison.rds")$phenocam_DB

# plot the data nicely
pdf("~/Figure_2_arrow_plot.pdf",7,5)
  arrow_plot(comparison, models = c("TT","PTT"), lwd = 3, length = 0.05)
dev.off()
