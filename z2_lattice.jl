using Agents
using IterTools
using GLMakie # GLMakie permite interactividad

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


"""
yang_mills_step!(agent, model)

Updates the angle of an edge agent by sampling from a Boltzmann distribution
conditional on the values of the edges in the faces that share the edge.

# Arguments
- `agent`: The edge agent to update.
- `model`: The model containing the agent.

# Returns
- `nothing`
"""
function yang_mills_step!(agent, model)::Nothing # Aquí podemos implementar multiple dispatch como en el tutorial (osea una que acepte ::Edge, otra que acepte ::Face, ::Vertex)
	β = model.β
	if variant(agent) isa Edge
		face_values = []
		for neighbour in nearby_agents(agent, model, 1)
			if variant(neighbour) isa Face
				face_members = SVector{3, Float64}(
					[other_edge.angle for other_edge in nearby_agents(neighbour, model, 1) if other_edge != agent]
				) # Ineficiente pero no se me ocurre cómo pitearme el agente propio sin sacarlo primero de la lista.
				push!(face_values, face_members)
			end
		end
		agent.angle = yang_mills_boltzmann(face_values..., β)[1] # Aprovecho Multiple Dispatch. Slay!
	end
	return nothing
end

"""
initialize_model(height::Int, width::Int, β::Float64)

Initializes a model with a grid of size `height` x `width` with a given β value.
This model is a 2D lattice with vertices, edges and faces. The vertices are initialized with no properties.
The edges are initialized with an angle of 1.0. The faces are initialized with a value of 1.0.

# Arguments
- `height::Int`: The height of the grid.
- `width::Int`: The width of the grid.
- `β::Float64`: The β value of the model.

# Returns
- `model`: The initialized model.
"""
function initialize_model(height::Int, width::Int, β::Float64)
	gridsize::Tuple{Int, Int} = (2 * height - 1, 2 * width - 1)
	space = GridSpaceSingle(gridsize; periodic = false, metric = :manhattan)
	properties = Dict(:β => β)
	model = StandardABM(
		Element,
		space;
		(agent_step!) = yang_mills_step!, properties,
		container = Vector
	) # TODO: Ver cómo hacer que el Scheduler sólo pesque a los edges (que son todo lo que nos interesa)

	# We add the vertices
	for (i, j) in product(2 .* (1:height) .- 1, 2 .* (1:width) .- 1)
		# agent = Element(Vertex(model, (i, j)))
		# add_agent_own_pos!(agent, model)
		add_agent!((i,j), constructor(Element, Vertex), model)
	end

	# We add the edges initialized with angle 1.0
	edge_positions = Iterators.flatten(
		(
		product(2 .* (1:height) .- 1, 2 .* (1:width-1)),
		product(2 .* (1:height-1), 2 .* (1:width) .- 1),
	)
	)
	for (i, j) in edge_positions
		# agent = Element(Edge(model, (i, j), 1.0))
		# add_agent_own_pos!(agent, model)
		add_agent!((i,j), constructor(Element, Edge), model; angle=0.0)
	end

	# We add the faces initialized with value 1.0
	for (i, j) in product(2 .* (1:height-1), 2 .* (1:width-1))
		# agent = Element(Face(model, (i, j), 1.0))
		# add_agent_own_pos!(agent, model)
		add_agent!((i,j), constructor(Element, Face), model; value=1.0)
	end

	return model
end

model = initialize_model(10, 10, 5.0)
step!(model, 100)
# Plotting
# Define a color function based on the agent type
agent_color(agent) = variant(agent) isa Edge ? "#FF0000" : variant(agent) isa Vertex ? "#0000FF" : "#FFFF00"

# Plot the model with the specified colors
figure, _ = abmplot(model; agent_color = agent_color)
# figure # returning the figure displays it
arrows!(
	[Point2f(edge.pos...) for edge in allagents(model) if variant(edge) isa Edge],
	[Vec2f(cos(edge.angle), sin(edge.angle)) for edge in allagents(model) if variant(edge) isa Edge]
	)
figure

# TODO: Hay que ver si esto tiene sentido. Y visualizarlo mejor! Pero en otro archivo...
