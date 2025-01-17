# library(tidyverse)
# library(RColorBrewer)
# library(ggpubr)
# theme_set(theme_bw())

# p <- c("#1a9850", "#ffd700", "#d73027")

# df <- read.table("Simulation-Results_Files/validation_5.2/2023_05_01_simulation_5_2_bias", fill = TRUE, sep = "\t")
# names(df) <- c("rep", "gen", "popstat", "spacer_1", "fwte", "avw", "min_w", "avtes", "avpopfreq",
#                "fixed", "spacer_2", "phase", "fwcli", "avcli", "fixcli", "spacer_3",
#                "avbias", "3tot", "3cluster", "spacer_4", "sampleid")

# df$phase <- factor(df$phase, levels = c("rapi", "trig", "shot", "inac"))
# df$sampleid <- factor(df$sampleid, levels = c("b0", "b50", "bm50"))

# # Determine common y-axis limits
# y_min <- min(df$avtes, na.rm = TRUE)
# y_max <- 1500

# plot_diploid <- function(data, title) {
#   ggplot(data, aes(x = gen, y = avtes, group = rep, color = phase)) +
#     geom_line(alpha = 1, linewidth = 0.7) +
#     xlab("Generation") +
#     ylab("TE insertions per diploid individual") +
#     ggtitle(title) +
#     scale_colour_manual(values = p) +
#     ylim(y_min, y_max) +  # Normalize y-axis
#     theme(
#       legend.position = "bottom",
#       plot.title = element_text(hjust = 0.5),
#       panel.grid.major = element_line(colour = "gray90"),
#       panel.grid.minor = element_line(colour = "gray95"),
#       strip.background = element_rect(fill = "lightgrey"),
#       strip.text = element_text(face = "bold"),
#       axis.text.x = element_text(margin = margin(t = 5))  # Increase x-axis margin
#     )
# }

# g1 <- plot_diploid(subset(df, sampleid == "bm50"), "Bias = -50")
# g2 <- plot_diploid(subset(df, sampleid == "b0"), "Bias = 0")
# g3 <- plot_diploid(subset(df, sampleid == "b50"), "Bias = 50")

# super_plot <- grid.arrange(g1, g2, g3, nrow = 1, widths = c(1, 1, 1))

# ggsave((filename = "images/te_invasion_diploid.jpg"), plot = super_plot, width = 10, height = 8, dpi = 600)
# # Plot the super plot
# print(super_plot)

library(tidyverse)
library(RColorBrewer)
library(ggpubr)
theme_set(theme_bw())

# Step 1: Load the dataframe
df <- read.table("Simulation-Results_Files/validation_5.2/2023_05_01_simulation_5_2_bias", 
                 header = FALSE, sep = "\t", fill = TRUE)


# Step 2: Assign column names
column_names <- c("rep", "gen", "popstat", "spacer_1", "fwte", "avw", "min_w", "avtes", 
                  "avpopfreq", "fixed", "spacer_2", "phase", "fwcli", "avcli", 
                  "fixcli", "spacer_3", "avbias", "3tot", "3cluster", "spacer_4", "sampleid")
names(df) <- column_names

# Step 3: Filter relevant columns and remove rows with NA in 'sampleid'
relevant_columns <- c("rep", "phase", "sampleid", "fwcli", "avcli", "avtes", "gen")
df <- df[, relevant_columns] %>% filter(!is.na(sampleid))

# Convert 'phase' to factors and set 'sampleid' with specific order
df$phase <- as.factor(df$phase)
df$sampleid <- factor(df$sampleid, levels = c("bm90", "bm80", "bm70", "bm60", "bm50",
                                               "bm40", "bm30", "bm20", "bm10", "b0", 
                                               "b10", "b20", "b30", "b40", "b50", 
                                               "b60", "b70", "b80", "b90"))

df <- filter(df, sampleid %in% c("bm50", "b0", "b50"))

# Divide in shot and inact phases
df1 <- subset(df, phase %in% c("shot", "inac"))
df2 <- data.frame()

# New dataframe with only the first shotgun & the first inactive phase of each replicate
repcheck <- 1
x <- 1
y <- 1
while (x < nrow(df1)) {
  if (repcheck != df1[x, 1]) {
    y <- 1
  }
  if (y == 1) {
    if (df1[x, 2] == "shot") {
      df2 <- rbind(df2, df1[x,])
      y <- 2
      repcheck <- df1[x, 1]
    }
  }
  if (y == 2) {
    if (df1[x, 2] == "inac") {
      df2 <- rbind(df2, df1[x,])
      y <- 1
    }
  }
  x <- x + 1
}

# Summary statistics
#df2 <- select(df2, -c(22))

df_count <- df2 %>%
  dplyr::count(sampleid, phase)

df_summary <- df2 %>%
  dplyr::group_by(sampleid, phase) %>%
  dplyr::summarize(av_fwcli = mean(fwcli), sd_fwcli = sd(fwcli),
                   av_cli = mean(avcli), sd_cli = sd(avcli), cv_cli_percent = sd(avcli) / mean(avcli),
                   av_tes = mean(avtes), sd_tes = sd(avtes), cv_tes_percent = sd(avtes) / mean(avtes),
                   length_previous_phase = mean(gen),
                   sd_gen_phases = sd(gen))
df_summary <- cbind(df_count$n, df_summary)

colnames(df_summary)[1] <- "n"

# CI 95%: z* sd/sqrt(population)
df_summary$ci_fwcli <- qt(0.975, df = df_summary$n - 1) * (df_summary$sd_fwcli / sqrt(df_summary$n))
df_summary$ci_cli <- qt(0.975, df = df_summary$n - 1) * (df_summary$sd_cli / sqrt(df_summary$n))
df_summary$ci_tes <- qt(0.975, df = df_summary$n - 1) * (df_summary$sd_tes / sqrt(df_summary$n))

# Filter the data
df_summary_filtered <- df_summary %>% filter(sampleid %in% c("bm50", "b0", "b50"))

# Plot
g_avtes <- ggplot(df_summary_filtered, aes(x = phase, y = av_tes, fill = phase)) +
  geom_bar(stat = "identity") +
  geom_errorbar(aes(x = phase, ymin = av_tes - sd_tes, ymax = av_tes + sd_tes), width = 0.2, colour = "black", alpha = 0.9, size = 0.8) +
  ylab("Insertions per individual") +
  xlab("Phase") +
  ggtitle("Bias vs TE Insertions") +
  theme(legend.position = "bottom",
        plot.title = element_text(hjust = 0.5),
        panel.grid.major = element_line(colour = "gray90"),
        panel.grid.minor = element_line(colour = "gray95"),
        strip.background = element_rect(fill = "lightgrey"),
        strip.text = element_text(face = "bold")) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.01))) +
  scale_fill_manual(values = c("#ffd700", "#d73027")) +
  facet_wrap(~sampleid, labeller = labeller(sampleid =
                                              c("b0" = "bias = 0",
                                                "b50" = "bias = 50",
                                                "bm50" = "bias = -50")))

# Print the plot
print(g_avtes)