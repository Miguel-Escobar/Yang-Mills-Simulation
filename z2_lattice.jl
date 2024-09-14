using Agents

@agent struct Edge(GridAgent{2})
    angle::Float64
end

@agent struct Vertex(GridAgent{2})
end

@agent struct Face(GridAgent{2})
    value::Float64
end

function face_value(face)
end

function yang_mills_step!(agent, model)
end

                
function initialize_model(height, width)
    size = (2*height - 1, 2*width - 1)
    space = GridSpaceSingle(size; periodic = false, metric = :manhattan)
    total_vertices = height*width
    total_faces = (height - 1)*(width - 1)
    total_edges = (2*height - 1)*(2*width - 1) - total_vertices - total_faces
    # model = StandardABM(
    #     Edge,
    #     space;
    #     scheduler = Schedulers.Randomly(),
    #     agent_step! = yang_mills_step!,
    #     container= Vector
    # )
    # for (i, pos) in enumerate(all_positions(model))
    #     orientation = rand(0:1)
    #     value = rand() * 2π
    #     agent = Edge(pos, orientation, value)
    #     add_agent!(agent, model)
    # end
    # return model
end

