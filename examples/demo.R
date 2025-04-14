# demo.R
#-------------------------------------------------------------------------------
# bioPalette Demo: Create, compile, extract, and preview custom color palettes
#-------------------------------------------------------------------------------

# Load all functions
source("R/load_all.R")
cli::cli_h1("bioPalette Demo: From Creation to Visualization")

# Step 1: Create a palette
cli::cli_alert_info("Creating palette: blues (sequential)")
create_palette(
  name = "blues",
  type = "sequential",
  colors = c("#deebf7", "#9ecae1", "#3182bd"),
  log = TRUE
)

# Step 2: Compile all palettes into an RDS
cli::cli_alert_info("Compiling palettes from 'colors/' to 'data/color_palettes.rds'")
compile_palettes(
  color_dir = "colors",
  output_rds = "data/color_palettes.rds",
  log = TRUE
)

# Step 3: Retrieve colors
cli::cli_alert_info("Retrieving 'blues' palette (3 colors)")
colors <- get_palette(
  name = "blues",
  type = "sequential",
  n = 3,
  palette_rds = "data/color_palettes.rds"
)
print(colors)

# Step 4: Preview palette
cli::cli_alert_info("Previewing 'blues' palette with bar plot")
preview_palette(
  name = "blues",
  type = "sequential",
  plot_type = "bar",
  palette_rds = "data/color_palettes.rds"
)
