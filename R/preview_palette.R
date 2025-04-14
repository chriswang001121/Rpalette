# R/preview_palette.R
#-------------------------------------------------------------------------------

# Color Palette Preview Tool: Extract colors from an RDS file and visualize them
#-------------------------------------------------------------------------------
#
# Background:
#   - This function previews the visual appearance of a color palette,
#     helping users select appropriate color schemes.
#   - It reads color palettes directly from an RDS file and supports various visualization methods.
#   - Supported plot types:
#     - bar: Bar plot to show color order and contrast.
#     - pie: Pie chart to display color distribution.
#     - point: Point plot to simulate data point colors.
#     - rect: Rectangle plot to display color blocks.
#     - circle: Circular plot with arranged dots.
#
# Parameters:
#   - name: Name of the color palette (string, e.g., "vividset")
#   - type: Type of palette, either "sequential", "diverging", or "qualitative" (default: "sequential")
#   - n: Number of colors to return (positive integer, default NULL uses all colors)
#   - plot_type: Type of plot, either "bar", "pie", "point", "rect", or "circle" (default: "bar")
#   - title: Title of the plot (default: name)
#   - palette_rds: Path to the RDS file (default: "colors/color_palettes.rds")
#
# Return Value:
#   - None (directly generates a visualization of the selected color palette).
#
# Dependencies:
#   - cli (for command-line interaction messages)

preview_palette <- function(name,
                            type = c("sequential", "diverging", "qualitative"),
                            n = NULL,
                            plot_type = c("bar", "pie", "point", "rect", "circle"),
                            title = name,
                            palette_rds = "data/color_palettes.rds") {

  # Load required package
  if (!requireNamespace("cli", quietly = TRUE)) {
    stop("Please install the cli package: install.packages('cli')", call. = FALSE)
  }

  # Load get_palette if not available
  if (!exists("get_palette", mode = "function")) {
    source("R/get_palette.R")
    cli::cli_alert_info("函数 get_palette() 自动加载完成")
  }

  # Validate plot_type
  plot_type <- match.arg(plot_type)

  # Extract colors (by get_palette)
  colors <- get_palette(name = name, type = type, n = n, palette_rds = palette_rds)
  num_colors <- length(colors)

  cli::cli_alert_success("Successfully extracted '{name}', number of colors: {.val {num_colors}}")

  # Generate the plot based on plot_type
  switch(plot_type,
         "bar" = {
           barplot(rep(1, num_colors),
                   col = colors,
                   border = NA,
                   space = 0,
                   axes = FALSE,
                   main = title,
                   names.arg = colors,
                   las = 2,  # Vertical HEX labels
                   cex.names = 0.8)  # Adjust font size
         },
         "pie" = {
           pie(rep(1, num_colors),
               col = colors,
               labels = colors,  # Show HEX codes
               border = "white",
               main = title,
               cex = 0.8)  # Adjust font size
         },
         "point" = {
           plot(seq_len(num_colors),
                rep(1, num_colors),
                pch = 19,
                cex = 5,
                col = colors,
                axes = FALSE,
                xlab = "",
                ylab = "",
                main = title)
           text(seq_len(num_colors),
                rep(1.2, num_colors),
                labels = colors,
                pos = 3,  # HEX labels above
                cex = 0.8)
         },
         "rect" = {
           plot(0, 0, type = "n",
                xlim = c(0, num_colors),
                ylim = c(0, 1),
                axes = FALSE,
                xlab = "",
                ylab = "",
                main = title)
           rect(0:(num_colors-1), 0, 1:num_colors, 1,
                col = colors,
                border = NA)
           text((0:(num_colors-1) + 1:num_colors) / 2, 0.5,
                labels = colors,
                col = "white",
                cex = 0.8)
         },
         "circle" = {
           plot(0, 0, type = "n",
                xlim = c(0, num_colors),
                ylim = c(0, 1),
                axes = FALSE,
                xlab = "",
                ylab = "",
                main = title)
           symbols(seq_len(num_colors) - 0.5, rep(0.5, num_colors),
                   circles = rep(0.4, num_colors),
                   inches = FALSE,
                   bg = colors,
                   add = TRUE)
           text(seq_len(num_colors) - 0.5, 0.5,
                labels = colors,
                col = "white",
                cex = 0.8)
         },
         stop("Unsupported plot type. Supported types: 'bar', 'pie', 'point', 'rect', 'circle'")
  )

  cli::cli_alert_info("Preview of '{name}' completed, plot type: {.val {plot_type}}, number of colors: {.val {num_colors}}")

  invisible(NULL)

}

#-------------------------------------------------------------------------------
# Example Usage: Preview color palettes
#-------------------------------------------------------------------------------

# Prerequisite: Assume compile_palettes() has generated colors/color_palettes.rds
# Available palettes:
# - qualitative/vividset (9 colors)
# - qualitative/softtrio (3 colors)
# - qualitative/harmonysix (6 colors)

# # Example 1: Preview vividset using a bar plot (all colors)
# preview_palette("vividset", type = "qualitative", plot_type = "bar")
#
# # Example 2: Preview softtrio using a pie chart
# preview_palette("softtrio", type = "qualitative", plot_type = "pie")
#
# # Example 3: Preview harmonysix using a point plot (first 4 colors)
# preview_palette("harmonysix", type = "qualitative", n = 4, plot_type = "point")
#
# # Example 4: Preview vividset using a rectangle plot (first 5 colors)
# preview_palette("vividset", type = "qualitative", n = 5, plot_type = "rect",
                # title = "VividSet Preview (5 Colors)")
#
# # Example 5: Preview softtrio using a circle plot
# preview_palette("softtrio", type = "qualitative", plot_type = "circle")

#-------------------------------------------------------------------------------
