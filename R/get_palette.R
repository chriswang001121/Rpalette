# R/get_palette.R
#-------------------------------------------------------------------------------

# Color Palette Extraction Tool: Extract a specified color palette from an RDS file
#-------------------------------------------------------------------------------
#
# Background:
#   - This function extracts color palettes from a compiled RDS file, allowing 
#     flexible control over the number of colors returned.
#   - The RDS file is generated using compile_palettes() and contains 
#     sequential, diverging, and qualitative color palettes.
#   - Features:
#     - Extract a color palette by name and type.
#     - Specify the number of colors to return (n).
#     - Automatically locate and suggest the correct type if a mismatch occurs.
#     - Returns HEX color values as a vector, ready for visualization or other applications.
#
# Parameters:
#   - name: Name of the color palette (string, e.g., "vividset")
#   - type: Type of palette, either "sequential", "diverging", or "qualitative" (default: "sequential")
#   - n: Number of colors to return (positive integer, default NULL returns all colors)
#   - palette_rds: Path to the RDS file (default: "colors/color_palettes.rds")
#
# Return Value:
#   - A character vector containing HEX color values of the specified palette.
#
# Dependencies:
#   - cli (for command-line interaction messages)

get_palette <- function(name, 
                        type = c("sequential", "diverging", "qualitative"),
                        n = NULL,
                        palette_rds = "colors/color_palettes.rds") {
  
  # Load required package
  if (!requireNamespace("cli", quietly = TRUE)) {
    stop("Please install the cli package: install.packages('cli')", call. = FALSE)
  }
  library(cli)
  
  # Check if the RDS file exists
  if (!file.exists(palette_rds)) {
    cli_alert_danger("Color palette file not found: {.path {palette_rds}}")
    stop("Please check the file path.")
  }
  
  # Read the RDS file
  palettes <- readRDS(palette_rds)
  
  # Validate the type
  valid_types <- names(palettes)
  type <- match.arg(type)
  if (!type %in% valid_types) {
    cli_alert_danger("Invalid type '{type}', available types: {.val {valid_types}}")
    stop("Type mismatch.")
  }
  
  # Validate the name parameter
  if (!is.character(name) || length(name) != 1) {
    stop("Palette name (name) must be a single string!")
  }
  
  # Check if the specified palette exists under the given type
  if (!name %in% names(palettes[[type]])) {
    # Search for the name in all types
    found_type <- NULL
    for (t in valid_types) {
      if (name %in% names(palettes[[t]])) {
        found_type <- t
        break
      }
    }
    
    if (is.null(found_type)) {
      cli_alert_danger("Palette '{name}' not found in any type.")
      stop("Palette does not exist.")
    } else {
      cli_alert_warning("Palette '{name}' not found in type '{type}', but found in '{found_type}'")
      cli_alert_info("Consider changing the type parameter to '{found_type}'.")
      stop("Type and name mismatch.")
    }
  }
  
  # Extract colors
  colors <- palettes[[type]][[name]]
  max_len <- length(colors)
  
  cli_alert_success("Successfully extracted '{name}', number of colors: {.val {max_len}}")
  
  # Return all colors if n is not specified
  if (is.null(n)) {
    return(colors)
  }
  
  # Validate n as a positive integer
  if (!is.numeric(n) || n != round(n) || n <= 0) {
    cli_alert_danger("Parameter 'n' must be a positive integer, current value: {.val {n}}")
    stop("n must be a positive integer.")
  }
  
  # Check if n exceeds the maximum available colors
  if (n > max_len) {
    stop(sprintf("Requested number of colors (%d) exceeds available colors in '%s' (%d)!", 
                 n, name, max_len))
  }
  
  # Return the requested number of colors
  return(colors[seq_len(n)])
}

#-------------------------------------------------------------------------------
# Example Usage: Extract color palettes from an RDS file
#-------------------------------------------------------------------------------

# Prerequisite: Assume compile_palettes() has generated colors/color_palettes.rds
# Available palettes:
# - qualitative/vividset (9 colors)
# - qualitative/softtrio (3 colors)
# - qualitative/harmonysix (6 colors)

# # Example 1: Extract all colors from 'vividset'
# colors_vividset <- get_palette("vividset", type = "qualitative")
# cat("Extracted all colors from 'vividset' (", length(colors_vividset), "):", 
#     paste(colors_vividset, collapse = ", "), "\n")
# 
# # Example 2: Extract a subset (first 2 colors) from 'softtrio'
# colors_softtrio <- get_palette("softtrio", type = "qualitative", n = 2)
# cat("Extracted first 2 colors from 'softtrio':", paste(colors_softtrio, collapse = ", "), "\n")
# 
# # Example 3: Extract exactly 6 colors from 'harmonysix'
# colors_harmonysix <- get_palette("harmonysix", type = "qualitative", n = 6)
# cat("Extracted 6 colors from 'harmonysix':", paste(colors_harmonysix, collapse = ", "), "\n")
# 
# # Example 4: Test incorrect type (vividset is in qualitative, but 'sequential' is given)
# # This will throw an error and suggest the correct type.
# get_palette("vividset", type = "sequential")
# 
# # Example 5: Test invalid n value (softtrio, n = 0)
# # This will throw an error indicating that n must be a positive integer.
# get_palette("softtrio", type = "qualitative", n = 0)
# 
# # Example 6: Test non-integer n value (softtrio, n = 1.5)
# # This will throw an error indicating that n must be a positive integer.
# get_palette("softtrio", type = "qualitative", n = 1.5)
# 
# # Example 7: Use extracted colors for visualization (first 5 colors of vividset)
# colors_vividset_5 <- get_palette("vividset", type = "qualitative", n = 5)
# barplot(rep(1, 5), col = colors_vividset_5, main = "vividset (5 colors)")

#-------------------------------------------------------------------------------
