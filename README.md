# bioPalette

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

This will:
1. Create a sequential palette (`blues`)
2. Compile all palettes into an RDS file
3. Extract colors from the RDS
4. Preview the palette visually

---

## 🎨 Built-in Color Palettes

The `colors/` folder contains pre-defined palettes in JSON format, ready to use:

```r
# Compile JSON palettes to RDS
compile_palettes("colors")

# Retrieve and preview the 'vividset' qualitative palette
get_palette("vividset", type = "qualitative")
preview_palette("vividset", type = "qualitative", plot_type = "bar")
```

Feel free to:
- 🔧 Modify them
- 🧪 Build your own
- 🚀 Contribute new palettes!

---

## 🖼️ Example: "VividSet" Palette

Here’s a bar preview of the qualitative palette **"vividset"**:

![vividset](output/preview/vividset_bar.png)

---

## 📁 Project Structure

```
bioPalette/
├── R/                   # All functions
├── colors/              # JSON palette definitions (by type)
├── data/                # Compiled palettes (RDS)
├── logs/                # Logs for palette creation and compilation
├── examples/            # Demo script and generated images
├── .gitignore           # Ignore R history, logs, temp files
└── README.md            # You’re here!
```

---

## ✅ To Do

- [ ] Add `save_palette()` to export selected palettes as PNG/SVG
- [ ] Add hex label toggle in previews
- [ ] Create `as_ggplot_palette()` function for direct ggplot2 usage
- [ ] Build a pkgdown site

---

## 🤝 Contributions

You're welcome to:
- Submit your own palettes (`colors/`)
- Suggest new features or improvements
- Report bugs or submit pull requests

---

## 📄 License

This project is licensed under the MIT License. See [`LICENSE`](LICENSE) for details.
```

---
