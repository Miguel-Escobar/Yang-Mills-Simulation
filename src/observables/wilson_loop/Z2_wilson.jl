"""
The objective of this module is to develope functionalities for Wilson Loops analysis.
"""

module z2_Wilson_Loop

current_dir = @__DIR__

z2_lattice_path = joinpath("..", "ambient_space", "z2_lattice.jl")

include(z2_lattice_path)

import .z2_lattice: initialize_model, Element, Edge, Vertex, Face

"""
W(gamma::Array)::Float64

Computes the Wilson Loop for a given path gamma.

# Arguments
- `gamma::Array`: The path for which the Wilson Loop will be computed. 
An array of tuples with an edge agent an a direction (1 for positive, -1 for negative. Up and right are possitive).

# Returns
- `Float64`: The Wilson Loop for the given path.
"""
function W(gamma::Array{Tuple{Edge, Int}, 1})::Float64

    loop = 1.0

    for (edge, direction) in gamma
        loop += direction * edge.angle

    # we return the element in the group Zn or U(1) corresponding to the angle
    return exp(2π * loop)

end

end