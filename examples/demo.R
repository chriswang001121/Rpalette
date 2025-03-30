# Rpalette Demo
library(jsonlite)
library(cli)

# 1. Create a color palette
source("../R/create_palette_json.R")
create_palette_json("blues", "sequential", c("#deebf7", "#9ecae1", "#3182bd"),
                    color_dir = "../output")  # Specify output directory

# 2. Compile the color palettes
source("../R/compile_palettes.R")
compile_palettes(color_dir = "../output",              # Input directory
                 output_rds = "../output/palettes.rds")  # Output RDS file

# 3. Retrieve colors
source("../R/get_palette.R")
colors <- get_palette("blues", "sequential", n = 3,
                      palette_rds = "../output/palettes.rds")  # Specify RDS path
print(colors)

# 4. Preview the color palette
source("../R/preview_palette.R")
preview_palette("blues", "sequential", plot_type = "bar",
                palette_rds = "../output/palettes.rds")  # Specify RDS path
