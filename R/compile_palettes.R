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
#   - log: Logical, whether to write log file (default = TRUE)
#
# Return Value:
#   - None (implicitly returns the output RDS file path); the result is saved as an RDS file.
#
# Dependencies:
#   - jsonlite (for JSON file reading and writing)
#   - cli (for command-line interaction messages)

compile_palettes <- function(color_dir = "colors",
                             output_rds = "data/color_palettes.rds",
                             log = TRUE) {

  # Load required packages
  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    stop("Please install the jsonlite package: install.packages('jsonlite')", call. = FALSE)
  }
  if (!requireNamespace("cli", quietly = TRUE)) {
    stop("Please install the cli package: install.packages('cli')", call. = FALSE)
  }

  cli::cli_h1("Starting color palette compilation (JSON → RDS)")

  # Read JSON files from specific subdirectories
  json_files <- unlist(lapply(c("sequential", "diverging", "qualitative"), function(subdir) {
    list.files(file.path(color_dir, subdir), pattern = "\\.json$", full.names = TRUE)
  }))

  if (length(json_files) == 0) {
    cli::cli_alert_warning("No JSON files found in {.path {color_dir}}.")
    return(invisible(NULL))
  }

  # Initialize palette collection
  palettes <- list(
    sequential = list(),
    diverging = list(),
    qualitative = list()
  )

  # Prepare logs
  log_path <- "logs/compile_palettes.log"
  if (log) dir.create(dirname(log_path), showWarnings = FALSE, recursive = TRUE)
  log_lines <- c(sprintf("\n=== [%s] Compilation started ===", Sys.time()))

  for (json_file in json_files) {

    palette_info <- tryCatch(jsonlite::fromJSON(json_file),
                             error = function(e) NULL)

    if (is.null(palette_info)) {
      msg <- sprintf("Failed to parse JSON: %s", json_file)
      cli::cli_alert_warning(msg)
      if (log) log_lines <- c(log_lines, sprintf("[%s] Warning: %s", Sys.time(), msg))
      next
    }

    required_fields <- c("name", "type", "colors")
    missing_fields <- setdiff(required_fields, names(palette_info))

    if (length(missing_fields) > 0) {
      msg <- sprintf("Missing required fields (%s) in: %s",
                     paste(missing_fields, collapse = ", "),
                     json_file)
      cli::cli_alert_warning(msg)
      if (log) log_lines <- c(log_lines, sprintf("[%s] Warning: %s", Sys.time(), msg))
      next
    }

    type <- palette_info$type
    name <- palette_info$name
    colors <- palette_info$colors

    if (!type %in% names(palettes)) {
      msg <- sprintf("Unknown type '%s', skipping: %s", type, json_file)
      cli::cli_alert_warning(msg)
      if (log) log_lines <- c(log_lines, sprintf("[%s] Warning: %s", Sys.time(), msg))
      next
    }

    # Validate color values
    if (!all(grepl("^#[0-9A-Fa-f]{6}([0-9A-Fa-f]{2})?$", colors))) {
      msg <- sprintf("Invalid HEX colors in: %s", json_file)
      cli::cli_alert_warning(msg)
      if (log) log_lines <- c(log_lines, sprintf("[%s] Warning: %s", Sys.time(), msg))
      next
    }

    # check duplicate
    if (name %in% names(palettes[[type]])) {
      cli::cli_alert_warning("Duplicate palette '{name}' in '{type}', overwriting.")
      if (log) log_lines <- c(log_lines, sprintf("[%s] Warning: Duplicate palette '%s' in '%s'", Sys.time(), name, type))
    }

    palettes[[type]][[name]] <- colors

    msg <- sprintf("Added '%s' (Type: %s, %d colors)", name, type, length(colors))
    cli::cli_alert_success(msg)
    if (log) log_lines <- c(log_lines, sprintf("[%s] Success: %s", Sys.time(), msg))
  }

  # Save compiled palette
  dir.create(dirname(output_rds), showWarnings = FALSE, recursive = TRUE)

  # Save RDS file
  tryCatch({
    saveRDS(palettes, file = output_rds)
    msg <- sprintf("Saved compiled RDS: %s", output_rds)
    cli::cli_alert_success(msg)
    if (log) log_lines <- c(log_lines, sprintf("[%s] Completed: %s", Sys.time(), msg))
  }, error = function(e) {
    msg <- sprintf("Failed to save RDS: %s", e$message)
    cli::cli_alert_danger(msg)
    if (log) log_lines <- c(log_lines, sprintf("[%s] Error: %s", Sys.time(), msg))
  })

  # Compilation Summary
  cli::cli_h2("Compilation Summary")
  cli::cli_alert_info("Sequential palettes:   {length(palettes$sequential)}")
  cli::cli_alert_info("Diverging palettes:    {length(palettes$diverging)}")
  cli::cli_alert_info("Qualitative palettes:  {length(palettes$qualitative)}")

  # Append compilation log
  if (log) {
    cat(paste(log_lines, collapse = "\n"), file = log_path, append = TRUE, sep = "\n")
    cat("✔ Compilation log saved to:", log_path, "\n")
  }

  cat("✔ RDS output saved to:", output_rds, "\n")

  invisible(output_rds)
}

#-------------------------------------------------------------------------------
# Example Usage: Compile color palettes and save as an RDS file
#-------------------------------------------------------------------------------

# Prerequisite: Assume the following palettes exist under "colors/":
#   colors/qualitative/vividset.json
#   colors/qualitative/softtrio.json
#   colors/qualitative/harmonysix.json

# Example 1: Compile all palettes using default settings
# compile_palettes()

# Example 2: Specify a custom output location
# compile_palettes(
#   color_dir = "colors",
#   output_rds = "data/custom_palettes.rds"
# )

# Example 3: Verify compilation results
# palettes <- readRDS("data/color_palettes.rds")
# length(unlist(palettes, recursive = FALSE))         # Total number of palettes
# palettes$qualitative$vividset                       # Preview one palette

#-------------------------------------------------------------------------------
