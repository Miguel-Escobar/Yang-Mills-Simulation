using ProgressMeter
using Plots

current_dir = @__DIR__

z2_visuals_path = joinpath(current_dir, "src", "ambient_space", "z2_visuals.jl")
z2_wilson_path = joinpath(current_dir, "src", "observables", "wilson_loop", "Z2_wilson.jl")

include(z2_visuals_path)
include(z2_wilson_path)

import .z2_visuals: interactive_exploration
import .z2_Wilson_Loop: get_V_func14

# Available groups: "U1", "Zn" (n=1, 2, 3, 4, 5, 6, ...)

group = "Z2"
height = 10
width = 10
β = 10.0
# interactive_exploration(height, width , β, group)

group = "Z3"
height = 100
width = 100
β = 0.1
n_samples = 1000
V_β = get_V_func14(width, height, β, group, n_samples)

# we plot Re(V), Im(V) and |V| for R_ in {1,2,..,height-1}
R_::Vector{Int} = 1:height-1

V_R_progress = Progress(length(R_), 1, "Computing V(R_)...")
_V_R_::Vector{Tuple{Int, Complex{Float64}}} = []
for r in R_
    push!(_V_R_, (r, V_β(r)))
    next!(V_R_progress)
end

# Extract the complex values from the tuples
complex_values = [x[2] for x in _V_R_]  # Create an array of ComplexF64 from tuples

# Now you can work with complex_values (which is a Vector{ComplexF64})
real_part = real.(complex_values)  # Real parts of the complex values
imaginary_part = imag.(complex_values)  # Imaginary parts of the complex values
norms = abs.(complex_values)  # Norm (magnitude) of the complex values

# Compute the ratio (x, y/x) for each plot
x_values = [x[1] for x in _V_R_]  # Extract x (the first element) from each tuple
real_part_ratio = real_part ./ x_values  # y/x for real part
imaginary_part_ratio = imaginary_part ./ x_values  # y/x for imaginary part
norms_ratio = norms ./ x_values  # y/x for norms

size = (1500, 1000)  # Size of the plots

# Create the plots for the real part
p1 = plot(real_part, label="Real Part", title="Real Part", xlabel="R", ylabel="Real", size=size)
p2 = plot(real_part_ratio, label="Real Part / R", title="Real Part / R", xlabel="R", ylabel="Real / R", size=size)

# Create the plots for the imaginary part
p3 = plot(imaginary_part, label="Imaginary Part", title="Imaginary Part", xlabel="R", ylabel="Imaginary", size=size)
p4 = plot(imaginary_part_ratio, label="Imaginary Part / R", title="Imaginary Part / R", xlabel="R", ylabel="Imaginary / R", size=size)

# Create the plots for the norm
p5 = plot(norms, label="Norm", title="Norm", xlabel="R", ylabel="Norm", size=size)
p6 = plot(norms_ratio, label="Norm / R", title="Norm / R", xlabel="R", ylabel="Norm / R", size=size)

# 7th plot: Colored scatter of the data (real part vs imaginary part) connected by a line
p7 = plot(real_part, imaginary_part, marker_z=1:length(real_part), c=:viridis, xlabel="Real Part", ylabel="Imaginary Part", title="Colored Scatter of Data", legend=false, colorbar_title="Index", linestyle=:auto, size=size)

# 8th plot: Colored scatter of the data divided by R (real part / R vs imaginary part / R) connected by a line
p8 = plot(real_part_ratio, imaginary_part_ratio, marker_z=1:length(real_part_ratio), c=:viridis, xlabel="Real Part / R", ylabel="Imaginary Part / R", title="Colored Scatter of Data / R", legend=false, colorbar_title="Index", linestyle=:auto, size=size)

# Ensure the 'data' directory exists
mkpath("data")
mkpath("data/$(height) x $(width) x $(β) x $(group) x $(n_samples)")

# Save the plots to the 'data' directory
savefig(p1, "data/$(height) x $(width) x $(β) x $(group) x $(n_samples)/Real Part.png")
savefig(p2, "data/$(height) x $(width) x $(β) x $(group) x $(n_samples)/Real Part div R.png")
savefig(p3, "data/$(height) x $(width) x $(β) x $(group) x $(n_samples)/Img Part.png")
savefig(p4, "data/$(height) x $(width) x $(β) x $(group) x $(n_samples)/Img Part div R.png")
savefig(p5, "data/$(height) x $(width) x $(β) x $(group) x $(n_samples)/Norm.png")
savefig(p6, "data/$(height) x $(width) x $(β) x $(group) x $(n_samples)/Norm div R.png")
savefig(p7, "data/$(height) x $(width) x $(β) x $(group) x $(n_samples)/All.png")
savefig(p8, "data/$(height) x $(width) x $(β) x $(group) x $(n_samples)/All div R.png")

println("Plots saved to the 'data' directory.")