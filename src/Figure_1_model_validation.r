# Figure 1.
#
# Model validation plot as shown when using
# the model validion function.
# Default parameters are used
library(phenor)

pdf("~/Figure_1_model_validation.pdf",7,5)
model_calibration(control = list(max.call = 40000,
                                temperature = 10000))
dev.off()
