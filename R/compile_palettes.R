# R/compile_palettes.R
#-------------------------------------------------------------------------------

# Color Palette Compilation Tool: Compile color palettes from JSON files and save as an RDS file
#-------------------------------------------------------------------------------
#
# Background:
#   - Color palettes are used in data visualization to distinguish categories,
#     display gradients, or highlight contrasts.
#   - This tool reads color palettes from JSON files in a specified directory,
#     compiles them into a unified structure, and saves them as an RDS file.
#   - Supports three types of color palettes:
#     - Sequential: Suitable for progressive data.
#     - Diverging: Suitable for highlighting middle values.
#     - Qualitative: Suitable for distinguishing discrete categories.
#   - The compilation process logs detailed messages, including success, warnings, and errors.
#
# Parameters:
#   - color_dir: Root directory containing JSON color palette files (default: "colors")
#   - output_rds: Path to save the compiled RDS file (default: "colors/color_palettes.rds")
#   - log_file: Path to save the compilation log (default: "colors/compile_palettes.log")
#
# Return Value:
#   - None (implicitly returns the output RDS file path); the result is saved as an RDS file.
#
# Dependencies:
#   - jsonlite (for JSON file reading and writing)
#   - cli (for command-line interaction messages)

compile_palettes <- function(color_dir = "colors",
                             output_rds = file.path(color_dir, "color_palettes.rds"),
                             log_file = file.path(color_dir, "compile_palettes.log")) {

  # Load required packages
  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    stop("Please install the jsonlite package: install.packages('jsonlite')", call. = FALSE)
  }
  if (!requireNamespace("cli", quietly = TRUE)) {
    stop("Please install the cli package: install.packages('cli')", call. = FALSE)
  }
  library(jsonlite)
  library(cli)

  cli_h1("Starting color palette compilation (JSON → RDS)")

  # Read JSON files from specific subdirectories
  json_files <- unlist(lapply(c("sequential", "diverging", "qualitative"), function(subdir) {
    list.files(file.path(color_dir, subdir), pattern = "\\.json$", full.names = TRUE)
  }))

  if (length(json_files) == 0) {
    cli_alert_warning("No JSON files found. Please check the directory: {.path {color_dir}}")
    return(invisible(NULL))
  }

  # Initialize palette collection
  palettes <- list(
    sequential = list(),
    diverging = list(),
    qualitative = list()
  )

  # Initialize compilation log
  compile_log <- c(sprintf("\n=== [%s] Compilation started ===", Sys.time()))

  for (json_file in json_files) {
    palette_info <- fromJSON(json_file)
    required_fields <- c("name", "type", "colors")

    if (!all(required_fields %in% names(palette_info))) {
      msg <- sprintf("Missing required fields in JSON, skipping: %s", json_file)
      cli_alert_warning(msg)
      compile_log <- c(compile_log, sprintf("[%s] Warning: %s", Sys.time(), msg))
      next
    }

    type <- palette_info$type
    name <- palette_info$name
    colors <- palette_info$colors

    if (!type %in% names(palettes)) {
      msg <- sprintf("Unknown color type '%s', skipping: %s", type, json_file)
      cli_alert_warning(msg)
      compile_log <- c(compile_log, sprintf("[%s] Warning: %s", Sys.time(), msg))
      next
    }

    # Validate color values
    if (!all(grepl("^#[0-9A-Fa-f]{6}([0-9A-Fa-f]{2})?$", colors))) {
      msg <- sprintf("Invalid HEX color values in: %s", json_file)
      cli_alert_warning(msg)
      compile_log <- c(compile_log, sprintf("[%s] Warning: %s", Sys.time(), msg))
      next
    }

    # check duplicate
    if (name %in% names(palettes[[type]])) {
      cli_alert_warning("Duplicate palette name '{name}' in type '{type}', overwriting.")
      compile_log <- c(compile_log, sprintf("[%s] Warning: Duplicate palette '%s' (Type: %s) was overwritten", Sys.time(), name, type))
    }

    palettes[[type]][[name]] <- colors

    msg <- sprintf("Successfully merged palette '%s' (Type: %s, Colors: %d)", name, type, length(colors))
    cli_alert_success(msg)
    compile_log <- c(compile_log, sprintf("[%s] Success: %s", Sys.time(), msg))
  }

  # Save RDS file
  tryCatch({
    saveRDS(palettes, file = output_rds)
    msg <- sprintf("All palettes saved to RDS file: %s", output_rds)
    cli_alert_success(msg)
    compile_log <- c(compile_log, sprintf("[%s] Completed: %s", Sys.time(), msg))
  }, error = function(e) {
    msg <- sprintf("Failed to save RDS: %s", e$message)
    cli_alert_danger(msg)
    compile_log <- c(compile_log, sprintf("[%s] Error: %s", Sys.time(), msg))
  })

  # Compilation Summary
  cli_h2("Compilation Summary")
  cli_alert_info("Sequential palettes: {length(palettes$sequential)}")
  cli_alert_info("Diverging palettes:  {length(palettes$diverging)}")
  cli_alert_info("Qualitative palettes: {length(palettes$qualitative)}")

  # Append compilation log
  cat(paste(compile_log, collapse = "\n"), file = log_file, append = TRUE, sep = "\n")
  cli_alert_info("Compilation log appended to: {.path {log_file}}")

  invisible(output_rds)
}

#-------------------------------------------------------------------------------
# Example Usage: Compile color palettes and save as an RDS file
#-------------------------------------------------------------------------------

# Prerequisite: Assume the following palettes were created using create_palette_json()
# colors/qualitative/vividset.json
# colors/qualitative/softtrio.json
# colors/qualitative/harmonysix.json

# # Example 1: Compile color palettes using the default path
# compile_palettes()
# cat("Color palettes compiled and saved to: colors/color_palettes.rds\n")
#
# # Example 2: Specify a custom output path
# compile_palettes(
#   color_dir = "colors",
#   output_rds = "data/custom_palettes.rds",
#   log_file = "data/compile_log.txt"
# )
# cat("Color palettes compiled and saved to: data/custom_palettes.rds\n")
#
# # Example 3: Verify compilation results
# palettes <- readRDS("colors/color_palettes.rds")
# print("Number of compiled color palettes:")
# print(length(unlist(palettes, recursive = FALSE)))
# print("Example palette (vividset):")
# print(palettes$qualitative$vividset)

#-------------------------------------------------------------------------------
