using GLMakie
include("z2_lattice.jl")

function model_energy(model::StandardABM)
    return sum(face.energy_value for face in allagents(model) if variant(face) isa Face)
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

function interactive_exploration(height, width, β::Float64)
    model = initialize_model(height, width, β)

    params = Dict(
    :β => 0:0.1:10.0
    )
    heatkwargs = (colorrange = (-1.0, 1.0), colormap = :inferno)

    plotkwargs = Dict(
    :add_controls => true,
    :heatarray => energy_array,
    :heatkwargs => heatkwargs
    )

    fig, abmobs = abmexploration(model; params=params, plotkwargs..., mdata=[model_energy], mlabel = ["Energy"])
    fig
end

