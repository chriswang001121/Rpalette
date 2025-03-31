# Rpalette

A simple R toolkit for managing and previewing color palettes in data visualization.

## Features
- Create custom palettes and save as JSON (`create_palette_json`).
- Compile JSON palettes into RDS (`compile_palettes`).
- Extract palettes from RDS (`get_palette`).
- Preview palettes with various plot types (`preview_palette`).

## Installation
Install dependencies:
```R
if (!requireNamespace("jsonlite", quietly = TRUE)) {
  install.packages("jsonlite")
}
if (!requireNamespace("cli", quietly = TRUE)) {
  install.packages("cli")
}
```

## Quick Start
```R
# Run demo
source("examples/demo.R")
```

## Shared Palettes
To help you get started, I've included a colors folder with some of my own color palettes! 🎨
- These are JSON files that you can directly use with Rpalette.
- Steps to use:
  1. Compile the JSON files into RDS format:
    ```R
    compile_palettes("colors")
    ```
    This will process all JSON files in the colors folder and save them as RDS files in the same directory.
  2. Load and preview a palette (e.g., vividset)
    ```R
    colors_vividset <- get_palette("vividset", type = "qualitative")

    preview_palette("vividset", type = "qualitative", plot_type = "bar")
    ``` 
- Feel free to explore, modify, or create your own palettes based on these examples!
## Example
Here’s a preview of the "Blues" palette included in the colors folder:
![Blues Palette](examples/blues_bar.png)

## Next Steps
- More documentation and examples coming soon!
- Contributions are welcome—feel free to submit your own palettes or suggest new features!