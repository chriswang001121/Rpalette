# Rpalette

A lightweight and flexible R toolkit for managing, compiling, and visualizing custom color palettes — designed especially for biological and scientific data visualization. 🎨

---

## ✨ Features

- 📦 **Create** your own color palettes and store them as JSON (`create_palette`)
- 🧩 **Compile** palettes into a fast-access RDS file (`compile_palettes`)
- 🎯 **Retrieve** palettes by name and type (`get_palette`)
- 🖼️ **Preview** palettes in multiple styles: bar, pie, point, rectangle, circle (`preview_palette`)
- 📚 **List** available palettes with summary info (`list_palettes`)
- 🌈 **Visualize** palettes by category in gallery view (`bio_palette_gallery`)

---

## 📦 Installation

Install required dependencies:

```r
install.packages("jsonlite")
install.packages("cli")
install.packages("ggplot2")
```

---

## 🚀 Quick Start

Run the full demo:

```r
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