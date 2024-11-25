module z2_visuals

using GLMakie
using Agents

current_dir = @__DIR__

z2_lattice_path = joinpath(current_dir, "z2_lattice.jl")
include(z2_lattice_path)

import .z2_lattice: initialize_model, Element, Edge, Vertex, Face

export interactive_exploration

function model_energy(model::StandardABM)
    return sum(face.energy_value for face in allagents(model) if variant(face) isa Face) # the agnet.energy_value was set to 0.0 for all non-face agents.
end

function energy_array(model::StandardABM)
    (height, width) = model.dimensions
    energy_matrix = zeros(2*height-1, 2*width-1)
    for face in allagents(model)
        if variant(face) isa Face
            energy_matrix[face.pos[1], face.pos[2]] = face.energy_value
        end
    end
    return energy_matrix
end

function interactive_exploration(height, width, β::Float64, group)
    GLMakie.activate!()

    model = initialize_model(height, width, β, group)

    params = Dict(
    :β => 0:0.1:10.0
    )
    heatkwargs = (colorrange = (-1.0, 1.0), colormap = :inferno)

    plotkwargs = Dict(
    :add_controls => true,
    :heatarray => energy_array,
    :heatkwargs => heatkwargs
    )

    agent_marker(a) = (a.pos[1] % 2 == 1 && a.pos[2] % 2 == 1) ? :circle : a.pos[1] % 2 == 1 ? :vline : a.pos[2] % 2 == 1 ? :hline : ' '
    agent_color(a) = variant(a) isa Vertex ? :blue : :black

    fig, abmobs = abmexploration(model; params=params, plotkwargs..., mlabels = ["Energy"], mdata=[model_energy], agent_marker = agent_marker, agent_color = agent_color)
    fig
end

end



