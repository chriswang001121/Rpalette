# Rpalette Demo
library(jsonlite)
library(cli)

# 1. 创建配色方案
source("../R/create_palette_json.R")
create_palette_json("blues", "sequential", c("#deebf7", "#9ecae1", "#3182bd"),
                    color_dir = "../output")  # 指定输出到 output/

# 2. 编译配色方案
source("../R/compile_palettes.R")
compile_palettes(color_dir = "../output",              # 输入目录
                 output_rds = "../output/palettes.rds")  # 输出 RDS 文件

# 3. 提取颜色
source("../R/get_palette.R")
colors <- get_palette("blues", "sequential", n = 3,
                      palette_rds = "../output/palettes.rds")  # 指定 RDS 路径
print(colors)

# 4. 预览配色
source("../R/preview_palette.R")
preview_palette("blues", "sequential", plot_type = "bar",
                palette_rds = "../output/palettes.rds")  # 指定 RDS 路径

