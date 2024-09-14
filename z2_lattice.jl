using Agents
include("U1_dist.jl")

@agent struct Edge(GridAgent{2})
    angle::Float64
end

@agent struct Vertex(GridAgent{2})
end

@agent struct Face(GridAgent{2})
    value::Float64
end

@multiagent Element(Edge, Vertex, Face)

function yang_mills_step!(agent, model)
    β = model.β
    if variant(agent) isa Edge
        face_values = []
        for neighbour in nearby_agents(agent, model, 1)
            if variant(neighbour) isa Face
                face_members = SVector{10, Float64}([other_edge.angle for other_edge in nearby_agents(neighbour, model, 1) if other_edge != agent]) # Ineficiente pero no se me ocurre cómo pitearme el agente propio sin sacarlo primero de la lista.
                push!(face_values, face_members)
            end
        end
        agent.angle = yang_mills_boltzmann(face_values..., β)[1] # Aprovecho Multiple Dispatch. Slay.
    end
end
                
function initialize_model(height, width, β)
    size = (2*height - 1, 2*width - 1)
    space = GridSpaceSingle(size; periodic = false, metric = :manhattan)
    total_vertices = height*width
    total_faces = (height - 1)*(width - 1)
    total_edges = (2*height - 1)*(2*width - 1) - total_vertices - total_faces
    model = StandardABM(
        Element,
        space;
        agent_step! = yang_mills_step!,
        container = Vector,
        scheduler = Schedulers.ByKind((:Edge,))
    )

    # TODO: Initialize agents with correct order of face, edge, and vertex.

    return model
end

# TODO: Implement a visualization routine (preferrably in another file)