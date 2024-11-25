include("..//src//ambient_space//z2_visuals.jl")
import .z2_visuals: interactive_exploration

height = 10
width = 10
β = 1.0
group = "Z100"

fig = interactive_exploration(height, width, β, group)
fig