using Agents

@agent struct Edge(GridAgent{2})
    const orientation::Int # 0 for horizontal, 1 for vertical
    value::Complex
end


function get_face_values(agent, model)
    close_positions = nearby_positions(agent, model, 1)
    if agent.orientation == 0
        face1 = agent.position .+ [(0, 0), (1, 0), (1, 1), (0, 1)]
        face2 = agent.position .+ [(0, 0), (-1, 0), (-1, 1), (0, 1)]
    else
        face1 = agent.position .+ [(0, 0), (-1, 0), (-1, 1), (0, 1)]
        face2 = agent.position .+ [(0, 0), (1, 0), (1, -1), (0, -1)]
    end
    face_values = zeros(2)
    for (i, face) in enumerate([face1, face2])
        if all(p -> in(p, close_positions), face)
            face_value = real(prod([get_agent(model, p).value for p in face]))
        else
            face_value = 0
        end
        face_values[i] = face_value
    end
    return face_values
end        

function yang_mills_step!(agent, model)
    
end

                
function initialize_model(height, width)
    size = (height, width)
    space = GridSpaceSingle(size; periodic = false, metric = :chebyshev)
    total_agents = height * width
    model = StandardABM(
        Edge,
        space;
        scheduler = Schedulers.Randomly(),
        agent_step! = yang_mills_step!
    )
    for i in 1:total_agents
        orientation = rand(0:1)
        value = exp(im * 2 * pi * rand())
        add_agent_single!(model; orientation = orientation, value = value)
    end
    return model
end

