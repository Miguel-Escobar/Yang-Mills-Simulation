using GLMakie
include("z2_lattice.jl")

function model_energy(model::StandardABM)
    return sum(face.energy_value for face in allagents(model) if variant(face) isa Face)
end

function interactive_exploration(_height, _width, β::Float64)
    model = initialize_model(_height, _width, β)

    params = Dict(
    :β => 0:0.1:10.0
    )
    plotkwargs = Dict(
    :add_controls => true
    )
    fig, ax, abmobs = abmplot(model; params, plotkwargs...) # TODO: Ojalá se pueda usar abmexploration
    fig
end


