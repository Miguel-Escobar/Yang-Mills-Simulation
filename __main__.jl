current_dir = @__DIR__

z2_visuals_path = joinpath(current_dir, "src", "ambient_space", "z2_visuals.jl")
z2_wilson_path = joinpath(current_dir, "src", "observables", "wilson_loop", "Z2_wilson.jl")

include(z2_visuals_path)
include(z2_wilson_path)

import .z2_visuals: interactive_exploration
import .z2_Wilson_Loop: W, V

# Available groups: "U1", "Zn" (n=1, 2, 3, 4, 5, 6, ...)

group = "Z2"
height = 10
width = 10
β = 10.0

interactive_exploration(height, width , β, group)
