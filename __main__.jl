current_dir = @__DIR__

z2_visuals_path = joinpath(current_dir, "src", "ambient_space", "z2_visuals.jl")

include(z2_visuals_path)

import .z2_visuals: interactive_exploration

# Available groups: "U1", "Zn" (n=1, 2, 3, 4, 5, 6, ...)

group = "Z2"
height = 10
width = 10
β = 10.0

interactive_exploration(height, width , β, group)