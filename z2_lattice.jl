using Agents
using IterTools
using CairoMakie # choosing a plotting backend
include("U1_dist.jl")

@agent struct Edge(GridAgent{2})
    angle::Float64
end

@agent struct Vertex(GridAgent{2})
end

@agent struct Face(GridAgent{2})
    value::Float64
end

@multiagent Element(Edge, Vertex, Face) <: AbstractAgent

function yang_mills_step!(agent, model)
    β = model.β
    if variant(agent) isa Edge
        face_values = []
        for neighbour in nearby_agents(agent, model, 1)
            if variant(neighbour) isa Face
                face_members = SVector{10,Float64}(
                    [other_edge.angle for other_edge in nearby_agents(neighbour, model, 1) if other_edge != agent]
                ) # Ineficiente pero no se me ocurre cómo pitearme el agente propio sin sacarlo primero de la lista.
                push!(face_values, face_members)
            end
        end
        agent.angle = yang_mills_boltzmann(face_values..., β)[1] # Aprovecho Multiple Dispatch. Slay!
    end
end

function initialize_model(height::Int, width::Int, β::Float64)
    gridsize::Tuple{Int, Int} = (2 * height - 1, 2 * width - 1)
    space = GridSpaceSingle(gridsize; periodic=false, metric=:manhattan)
    properties = Dict(:β => β)
    model = StandardABM(
        Element,
        space;
        (agent_step!)=yang_mills_step!, properties,
        container=Vector,
        scheduler=Schedulers.ByKind((:Edge,)),
    )

    # We add the vertices
    for (i, j) in product(2 .* (1:height) .- 1, 2 .* (1:width) .- 1)
        agent = Element(Vertex(model, (i, j)))
        add_agent_own_pos!(agent, model)
    end

    # We add the edges initialized with angle 1.0
    edge_positions = Iterators.flatten(
            (
            product(2 .* (1: height) .- 1, 2 .* (1: width - 1)),
            product(2 .* (1: height - 1), 2 .* (1: width) .- 1)
            )
        )
    for (i, j) in edge_positions
        agent = Element(Edge(model, (i, j), 1.0))
        add_agent_own_pos!(agent, model)
    end

    # We add the faces initialized with value 1.0
    for (i, j) in product(2 .* (1: height - 1), 2 .* (1: width - 1))
        agent = Element(Face(model, (i, j), 1.0))
        add_agent_own_pos!(agent, model)
    end

    return model
end

model = initialize_model(2, 2, 1.0)

# Plotting
figure, _ = abmplot(model)
figure # returning the figure displays it

# TODO: Implement a visualization routine (preferrably in another file)
