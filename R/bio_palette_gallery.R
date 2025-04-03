# R/bio_palette_gallery.R
#-------------------------------------------------------------------------------

# Color Palette Gallery Viewer: Visualize palettes by type in paged gallery view
#-------------------------------------------------------------------------------
#
# Background:
#   - This tool displays all palettes saved in a compiled RDS file, with color blocks arranged in neat rows.
#   - Supports three types of palettes:
#     - Sequential: Suitable for continuous data.
#     - Diverging: Suitable for centered gradients.
#     - Qualitative: Suitable for categorical variables.
#   - Palettes are sorted by number of colors (desc) and name (asc).
#   - Paging is applied (default: 30 palettes per page).
#
# Parameters:
#   - palette_rds: Path to the RDS file containing color palettes (default: "colors/color_palettes.rds")
#   - type: Types of palettes to display; supports "sequential", "diverging", "qualitative"
#   - max_palettes: Maximum number of palettes per page (default: 30)
#   - max_row: Maximum number of colors per row (default: 12)
#   - verbose: Logical, whether to print messages to console (default: TRUE)
#
# Return Value:
#   - A named list of ggplot objects (one per page), invisibly returned
#
# Dependencies:
#   - ggplot2
#   - cli (for messaging)

bio_palette_gallery <- function(palette_rds = "colors/color_palettes.rds",
                                type = c("sequential", "diverging", "qualitative"),
                                max_palettes = 30,
                                max_row = 12,
                                verbose = TRUE) {

  # Load required packages
  if (!requireNamespace("cli", quietly = TRUE)) {
    stop("Please install the cli package: install.packages('cli')", call. = FALSE)
  }

  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("Please install ggplot2: install.packages('ggplot2')", call. = FALSE)
  }

  library(ggplot2)
  library(cli)

  # Validate input file
  if (!file.exists(palette_rds)) {
    cli_alert_danger("RDS file does not exist: {.path {palette_rds}}")
    return(invisible(NULL))
  }

  # Try loading palette file
  palettes <- tryCatch({
    readRDS(palette_rds)
  }, error = function(e) {
    cli_alert_danger("Failed to read RDS file: {e$message}")
    return(invisible(NULL))
  })

  # Validate type parameter
  type <- match.arg(type, several.ok = TRUE)
  available_types <- names(palettes)
  selected_types <- intersect(type, available_types)

  if (length(selected_types) == 0) {
    cli_alert_warning("No palettes found for type: {paste(type, collapse = ', ')}. Available types: {paste(available_types, collapse = ', ')}")
    return(invisible(NULL))
  }

  # Check max_palettes
  if (!is.numeric(max_palettes) || max_palettes <= 0 || max_palettes %% 1 != 0) {
    cli_alert_danger("max_palettes must be a positive integer.")
    return(invisible(NULL))
  }

  # Check max_row
  if (!is.numeric(max_row) || max_row <= 0 || max_row %% 1 != 0) {
    cli_alert_danger("max_row must be a positive integer.")
    return(invisible(NULL))
  }

  cli_h1("Rendering color palettes of type: {paste(selected_types, collapse = ', ')}")

  plots <- list()

  for (type_val in selected_types) {
    type_palettes <- palettes[[type_val]]
    pal_info <- data.frame(
      name = as.character(names(type_palettes)),
      n = as.numeric(sapply(type_palettes, length)),
      stringsAsFactors = FALSE
    )
    pal_info <- pal_info[order(-pal_info$n, pal_info$name), ]

    total <- nrow(pal_info)
    pages <- ceiling(total / max_palettes)

    if (total == 0) {
      cli_alert_warning("⚠ No palettes available for type: {type_val}")
      next  # Skip this type if no palettes are available
    }

    if (verbose) cli_alert_info("Type {.strong {type_val}}: {total} palettes → {pages} page(s)")

    for (pg in seq_len(pages)) {
      idx_start <- (pg - 1) * max_palettes + 1
      idx_end <- min(pg * max_palettes, total)
      page_info <- pal_info[idx_start:idx_end, ]

      y_offset <- 0

      # Pre-allocate memory for plot data
      plot_data <- data.frame(type = character(),
                              name = character(),
                              x = numeric(),
                              y = numeric(),
                              color = character(),
                              stringsAsFactors = FALSE)

      label_data <- data.frame(name = character(),
                               x = numeric(),
                               y = numeric(),
                               stringsAsFactors = FALSE)

      type_label_data <- data.frame(
        type = type_val,
        label = paste0("—— ", type_val, " ——"),
        x = 6, y = y_offset + 0.5
      )
      y_offset <- y_offset - 1.5

      for (pal_name in page_info$name) {
        pal_colors <- type_palettes[[pal_name]]
        n_colors <- length(pal_colors)
        n_rows <- ceiling(n_colors / max_row)

        for (r in 1:n_rows) {
          idx_s <- (r - 1) * max_row + 1
          idx_e <- min(r * max_row, n_colors)
          colors <- pal_colors[idx_s:idx_e]

          # Directly add the new data row
          plot_data <- rbind(plot_data, data.frame(
            type = type_val,
            name = pal_name,
            x = seq_len(length(colors)) * 2,
            y = y_offset,
            color = colors,
            stringsAsFactors = FALSE
          ))
          label_data <- rbind(label_data, data.frame(name = pal_name, x = 0.8, y = y_offset))
          y_offset <- y_offset - 1.5
        }

        y_offset <- y_offset - 0.5
      }

      max_x <- max(plot_data$x)
      p <- ggplot(plot_data, aes(x = x, y = y, fill = color)) +
        geom_tile(width = 1.8, height = 0.7) +
        geom_text(data = label_data,
                  aes(x = x, y = y, label = name),
                  hjust = 1, size = 3.6, inherit.aes = FALSE) +
        geom_text(data = type_label_data,
                  aes(x = x, y = y, label = label),
                  size = 5, fontface = "bold", color = "#444444", inherit.aes = FALSE) +
        scale_fill_identity() +
        scale_x_continuous(expand = c(0, 0)) +
        coord_fixed(xlim = c(-2, max_x + 2), clip = "off") +
        theme_void() +
        theme(plot.margin = margin(20, 20, 20, 20))

      key <- paste0(type_val, "_page", pg)
      plots[[key]] <- p
    }

    # Only print if pages > 0
    if (pages >= 1) {
      print(plots[[paste0(type_val, "_page1")]])
      if (verbose) cli_alert_success("Rendered {.strong {type_val}} → page 1 of {pages}")
    }
  }

  invisible(plots)
}


#-------------------------------------------------------------------------------
# Example Usage: Visualize color palettes by type
#-------------------------------------------------------------------------------

# # Example 1: Show all palettes (default types, default layout)
# bio_palette_gallery()
#
# # Example 2: Only show qualitative color palettes
# bio_palette_gallery(type = "qualitative")
#
# # Example 3: Show sequential palettes with smaller layout (15 palettes per page, max 8 colors per row)
# bio_palette_gallery(type = "sequential", max_palettes = 15, max_row = 8)
