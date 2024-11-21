"""
The objective of this module is to develope functionalities for Wilson Loops analysis.
"""

module z2_Wilson_Loop

using Agents
using Statistics

current_dir = @__DIR__

z2_lattice_path = joinpath("..", "..", "ambient_space", "z2_lattice.jl")

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
function W(γ::Array{Tuple{Edge, Int}, 1})::Float64

    loop = 0.0

    for (edge, direction) in γ
        loop += direction * edge.angle
    end

    # we return the element in the group Zn or U(1) corresponding to the angle
    return e^(im * loop)

end

"""
V(model:: StandardABM, R:: int)::Float64

Computes the potential between a static quark and antiquark separated by distance R.

# Arguments
- `model:: StandardABM`: The model in which the potential will be computed.
- `R:: int`: The distance between the quark and antiquark.

# Returns
- `Float64`: The potential between the quark and antiquark separated by distance R.


We use the formula

V(R) = - lim_{T → ∞} (1/T) log⟨W(γ_{R,T})⟩ 

where γ_{R,T} is a path of length T and breadth R and ⟨ ⋅ ⟩ denotes the expectation value.
"""
function V(model:: StandardABM, R:: Int, n_samples:: Int = 1000)::Complex{Float64}

    h_vertices, v_vertices = model.dimensions
    T::Int = h_vertices - 1

    # we reach equilibrium
    step!(model, 1000) # NO GUARANTEE OF CONVERGENCE

    # we use the bottom left as reference point.
    samples:: Array{Int, 1} = 2 .* rand(1:v_vertices - R, n_samples) .- 1
    bottom_left_vertices:: Array{Int, 2} = hcat(ones(Int, n_samples), samples)

    # we compute the Wilson Loop for each sample
    wilson_loops:: Array{Complex{Float64}, 1} = []
    for bottom_left in eachrow(bottom_left_vertices)
        step!(model, 1)
        γ::Array{Tuple{Edge, Int}, 1} = []
        position::Array{Int, 1} = bottom_left # vertex we at
        for _ in 1:T
            position += [2, 0]
            ID = id_in_position(position - [1, 0], model)
            edge = model[ID]
            push!(γ, (edge, 1))
        end
        for _ in 1:R
            position += [0, 2]
            ID = id_in_position(position - [0, 1], model)
            edge = model[ID]
            push!(γ, (edge, 1))
        end
        for _ in 1:T
            position -= [2, 0]
            ID = id_in_position(position + [1, 0], model)
            edge = model[ID]
            push!(γ, (edge, -1))
        end
        for _ in 1:R
            position -= [0, 2]
            ID = id_in_position(position + [0, 1], model)
            edge = model[ID]
            push!(γ, (edge, -1))
        end

        push!(wilson_loops, W(γ))

    end

    E_Wγ::Complex{Float64} = mean(wilson_loops)

    V_R::Complex{Float64}  = - log(E_Wγ) / T

    return V_R

end

end

