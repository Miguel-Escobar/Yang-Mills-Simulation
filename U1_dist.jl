using ApproxFun
using StaticArrays


"""
yang_mills_boltzmann(first_face_neighbours::SVector{3,Float64}, second_face_neighbours::SVector{3,Float64}, β; n_samples::Int=1)::Vector{Float64}

Computes the Yang-Mills Boltzmann distribution for a given set of face neighbours and a β value.

# Arguments
- `first_face_neighbours::SVector{3,Float64}`: The angles of the edges in the first face.
- `second_face_neighbours::SVector{3,Float64}`: The angles of the edges in the second face.
- `β::Float64`: The β value of the distribution.
- `n_samples::Int=1`: The number of samples to draw from the distribution.

# Returns
- `samples`: The samples drawn from the distribution.
"""
function yang_mills_boltzmann(
    first_face_neighbours::SVector{3, Float64},
    second_face_neighbours::SVector{3, Float64},
    β;
    n_samples::Int = 1
    )::Vector{Float64}

	pdf = Fun(
        θ -> exp.(β .* (cos.(sum(first_face_neighbours) .+ θ) .+ cos.(sum(second_face_neighbours) .+ θ))),
        Interval(0.0, 2π)
        )
	samples = sample(pdf, n_samples)

	return samples
end

"""
yang_mills_boltzmann(only_face_neighbours::SVector{3, Float64}, β; n_samples::Int=1)::Vector{Float64}

Computes the Yang-Mills Boltzmann distribution for a given set of face neighbours and a β value.
Used for faces with only one neighbouring face.

# Arguments
- `only_face_neighbours::SVector{3,Float64}`: The angles of the edges in the face.
- `β::Float64`: The β value of the distribution.
- `n_samples::Int=1`: The number of samples to draw from the distribution.

# Returns
- `samples`: The samples drawn from the distribution.
"""
function yang_mills_boltzmann(
    only_face_neighbours::SVector{3, Float64},
    β; n_samples::Int = 1
    )::Vector{Float64}

	pdf = Fun(
        θ -> exp.(β .* (cos.(sum(only_face_neighbours) .+ θ))),
        Interval(0.0, 2π)
        )
	samples = sample(pdf, n_samples)
    
	return samples
end
