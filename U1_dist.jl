using ApproxFun
using StaticArrays

function yang_mills_boltzmann(first_face_neighbours::SVector{3,Float64}, second_face_neighbours::SVector{3,Float64}, β; n_samples::Int=1)::Vector{Float64}
    pdf = Fun(θ -> exp.(β .* (cos.(sum(first_face_neighbours) .+ θ) .+ cos.(sum(second_face_neighbours) .+ θ))), Interval(0.0, 2π))
    samples = sample(pdf, n_samples)
    println(typeof(samples))
    return samples
end

function yang_mills_boltzmann(only_face_neighbours::SVector{3, Float64}, β; n_samples::Int=1)
    pdf = Fun(θ -> exp.(β .* (cos.(sum(only_face_neighbours) .+ θ))), Interval(0.0, 2π))
    samples = sample(pdf, n_samples)
    return samples
end
