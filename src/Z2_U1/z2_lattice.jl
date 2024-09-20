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
	energy_value::Float64
end

@multiagent Element(Edge, Vertex, Face) <: AbstractAgent

function update_value!(face::Element, model::StandardABM)
	@assert variant(face) isa Face
	β = model.β
	ordered_neighbor_ids = id_in_position.(SA[(0, -1) .+ face.pos, (1, 0) .+ face.pos, (0, 1) .+ face.pos, (-1, 0) .+ face.pos], [model])
	signs = SA[1, 1, -1, -1]
	face_angles = [model[i].angle * sign for (i, sign) in zip(ordered_neighbor_ids, signs)]
	face.energy_value = -β*cos(sum(face_angles))
end

function partial_face_angle(face::Element, edge::Element, model::StandardABM)
	@assert variant(face) isa Face && variant(edge) isa Edge
	ordered_neighbor_ids = id_in_position.(SA[(0, -1) .+ face.pos, (1, 0) .+ face.pos, (0, 1) .+ face.pos, (-1, 0) .+ face.pos], [model])
	signs = SA[1, 1, -1, -1]
	partial_face_angle = sum([sign*model[i].angle for (i, sign) in zip(ordered_neighbor_ids, signs) if model[i] != edge])
	edge_sign = signs[edge.id .== ordered_neighbor_ids][1]
	return partial_face_angle, edge_sign
end

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
function yang_mills_step!(agent, model, ::Edge)::Nothing # Aquí podemos implementar multiple dispatch como en el tutorial (osea una que acepte ::Edge, otra que acepte ::Face, ::Vertex)
	β = model.β
	face_values::Vector{Float64} = []
	edge_signs::Vector{Int} = []
	for neighbour in nearby_agents(agent, model, 1)
		if variant(neighbour) isa Face
			partial_angle, edge_sign = partial_face_angle(neighbour, agent, model)
			push!(face_values, partial_angle)
			push!(edge_signs, edge_sign)
		end
	end
	agent.angle = yang_mills_boltzmann(face_values...,edge_signs[1], β)[1] # Aprovecho Multiple Dispatch. Slay!
	return nothing
end

function yang_mills_step!(agent, model, ::Face)::Nothing
	update_value!(agent, model)
	return nothing
end

function yang_mills_step!(agent, model, ::Vertex)::Nothing
	return nothing
end

yang_mills_step!(agent, model) = yang_mills_step!(agent, model, variant(agent))

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
		container = Vector,
		scheduler = Schedulers.ByID()
	) # TODO: Ver cómo controlar mejor el Scheduler

	# We add the vertices
	for (i, j) in product(2 .* (1:height) .- 1, 2 .* (1:width) .- 1)
		add_agent!((i,j), constructor(Element, Vertex), model)
	end

	# We add the edges initialized with angle pi/2
	edge_positions = Iterators.flatten(
		(
		product(2 .* (1:height) .- 1, 2 .* (1:width-1)),
		product(2 .* (1:height-1), 2 .* (1:width) .- 1),
	)
	)
	for (i, j) in edge_positions
		add_agent!((i,j), constructor(Element, Edge), model; angle=pi/2)
	end

	# We add the faces initialized with value -β
	for (i, j) in product(2 .* (1:height-1), 2 .* (1:width-1))
		add_agent!((i,j), constructor(Element, Face), model; energy_value=-β)
	end

	return model
end

# model = initialize_model(100, 100, 10.0)
# step!(model, 100)

# # Plottinga
# agent_color(agent) = variant(agent) isa Edge ? "#FF0000" : variant(agent) isa Vertex ? "#0000FF" : :yellow
# fig, ax, _ = abmplot(model; agent_color = agent_color)
# arrows!(ax,
# 	[Point2f(edge.pos...) for edge in allagents(model) if variant(edge) isa Edge],
# 	[Vec2f(cos(edge.angle), sin(edge.angle)) for edge in allagents(model) if variant(edge) isa Edge]
# )


# ax2 = Axis(fig[1, 2])
# hist!(ax2, [face.energy_value for face in allagents(model) if variant(face) isa Face], bins=10, normalization=:pdf)

# window = display(fig)

# TODO: Hay que ver si esto tiene sentido. Y visualizarlo mejor! Pero en otro archivo...
