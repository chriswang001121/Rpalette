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

## Example
![Blues Palette](examples/blues_bar.png)

## Next Steps

More documentation and examples coming soon!