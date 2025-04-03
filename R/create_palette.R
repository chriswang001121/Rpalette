# R/create_palette.R
#-------------------------------------------------------------------------------

# Color Palette Creation Tool: Save custom color palettes as JSON using jsonlite
#-------------------------------------------------------------------------------
#
# Background:
#   - Color palettes play a crucial role in data visualization, helping to
#     distinguish categories, display gradients, or create contrasts.
#   - JSON is a lightweight and cross-platform format, making it convenient
#     for storing and sharing custom color palettes.
#   - This function provides the following features:
#     - Create and save custom color palettes as JSON files.
#     - Supports three types of color palettes:
#       - Sequential: Suitable for progressive data.
#       - Diverging: Suitable for highlighting middle values.
#       - Qualitative: Suitable for distinguishing discrete categories.
#     - Automatically logs creation records for tracking and management.
#
# Parameters:
#   - name: Name of the color palette (string, e.g., "Blues")
#   - type: Type of palette, either "sequential", "diverging", or "qualitative" (default: "sequential")
#   - colors: Vector of hexadecimal color values (supports transparency, e.g., "#E64B35B2")
#   - color_dir: Root directory where the color palette is saved (default: "colors")
#   - log_file: Path to save the log file (default: "colors/palette_creation.log")
#
# Return Value:
#   - None (implicitly returns the JSON file path); the result is saved as a JSON file and logged.
#
# Dependencies:
#   - jsonlite (for reading and writing JSON files)
#   - cli (for command-line interaction messages)

create_palette <- function(name,
                                type = c("sequential", "diverging", "qualitative"),
                                colors,
                                color_dir = "colors",
                                log_file = file.path(color_dir, "palette_creation.log")) {

  # Load required packages
  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    stop("Please install the jsonlite package: install.packages('jsonlite')", call. = FALSE)
  }
  if (!requireNamespace("cli", quietly = TRUE)) {
    stop("Please install the cli package: install.packages('cli')", call. = FALSE)
  }
  library(jsonlite)
  library(cli)

  type <- match.arg(type)

  # Validate color values
  if (!all(grepl("^#[0-9A-Fa-f]{6}([0-9A-Fa-f]{2})?$", colors))) {
    stop("Color values must be valid HEX codes, e.g., '#FF5733' or '#FF5733B2'")
  }

  # Validate the name parameter
  if (!is.character(name) || length(name) != 1) {
    stop("Palette name (name) must be a single string!")
  }

  # Check and create directory if needed
  palette_dir <- file.path(color_dir, type)
  if (!dir.exists(palette_dir)) {
    dir.create(palette_dir, recursive = TRUE)
    cli_alert_info("Directory automatically created: {.path {palette_dir}}")
  }

  # Construct the color palette list
  palette_info <- list(
    name = name,
    type = type,
    colors = colors
  )

  # Define JSON file path
  json_file <- file.path(palette_dir, paste0(name, ".json"))

  # Check if the file already exists
  if (file.exists(json_file)) {
    cli_alert_warning("File already exists: {.path {json_file}}, it will be overwritten")
    return(invisible(NULL))
  }

  # Save as JSON
  tryCatch({
    write_json(palette_info, path = json_file, pretty = TRUE, auto_unbox = TRUE)
    cli_alert_success("Successfully created color palette JSON file: {.path {json_file}}")
  }, error = function(e) {
    cli_alert_danger("Failed to save JSON file: {e$message}")
    stop(e)
  })

  # Log the creation process
  log_entry <- paste(Sys.time(),
                     "| Type:", type,
                     "| Name:", name,
                     "| Number of colors:", length(colors),
                     "| Path:", json_file,
                     "\n")

  tryCatch({
    cat(log_entry, file = log_file, append = TRUE)
    cli_alert_info("Log entry appended to file: {.path {log_file}}")
  }, error = function(e) {
    cli_alert_danger("Failed to record log: {e$message}")
  })

  # Return file path (implicitly)
  invisible(list(path = json_file, info = palette_info))
}

#-------------------------------------------------------------------------------
# Example Usage: Create and save color palettes as JSON files
#-------------------------------------------------------------------------------
#
# # Example 1: Create a Sequential-type color palette "blues"
# create_palette(
#   name = "blues",
#   type = "sequential",
#   colors = c("#deebf7", "#9ecae1", "#3182bd")
# )
# cat("Sequential color palette created: colors/sequential/blues.json\n")
#
# # Example 2: Create a Diverging-type color palette "piyg" (with transparency)
# create_palette(
#   name = "piyg",
#   type = "diverging",
#   colors = c("#E64B35B2", "#00A087B2", "#3C5488B2")
# )
# cat("Diverging color palette created: colors/diverging/piyg.json\n")
#
# # Example 3: Create a Qualitative-type color palette "vividset"
# create_palette(
#   name = "vividset",
#   type = "qualitative",
#   colors = c("#E64B35", "#4DBBD5", "#00A087", "#3C5488", "#F39B7F")
# )
# cat("Qualitative color palette created: colors/qualitative/vividset.json\n")

#-------------------------------------------------------------------------------
