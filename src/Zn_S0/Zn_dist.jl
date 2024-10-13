using StaticArrays
using StatsBase

"""
yang_mills_boltzmann(
    first_partial_value::Int,
    second_partial_value::Int,
    edge_sign::Int,
    β::Float64;
    n_samples::Int=1,
    n::Int=2
)::Vector{Int}

Computes the Yang-Mills Boltzmann distribution for a given pair of partial values and a β value.

# Arguments
- `first_partial_value::Int`: The partial value associated with the first face.
- `second_partial_value::Int`: The partial value associated with the second face.
- `edge_sign::Int`: The sign of the edge.
- `β::Float64`: The β value of the distribution.
- `n_samples::Int=1`: The number of samples to draw from the distribution.
- `n::Int=2`: Corresponds to the n in Z/nZ, the group from which the values of the edges will be drawn.

# Returns
- `Vector{Int}`: The samples drawn from the distribution.
"""
function yang_mills_boltzmann(
    first_partial_value::Float64,
    second_partial_value::Float64,
    edge_sign::Int,
    β::Float64;
    n_samples::Int=1,
    n::Int=2
)::Vector{Int}

    # Calculate unnormalized probabilities for m = 0, 1, ..., n-1
    probs = [exp(β * (cos(2π * (first_partial_value + edge_sign * m) / n) +
                      cos(2π * (second_partial_value - edge_sign * m) / n))) for m in 0:n-1]

    # Normalize the probabilities to sum to 1
    normalized_probs = probs / sum(probs)

    # Use StatsBase for weighted sampling
    items = 0:n-1
    weights = Weights(normalized_probs)

    # Sample from the items using the weighted probabilities
    samples = [StatsBase.sample(items, weights) for _ in 1:n_samples]

    return samples
end

"""
yang_mills_boltzmann(
    only_partial_value::Float64,
    edge_sign::Int,
    β::Float64;
    n_samples::Int=1
)::Vector{Float64}

Computes the Yang-Mills Boltzmann distribution for a given partial value and a β value.
Used for faces with only one neighbouring face.

# Arguments
- `only_partial_value::Float64`: The partial value associated with the face.
- `edge_sign::Int`: The sign of the edge.
- `β::Float64`: The β value of the distribution.
- `n_samples::Int=1`: The number of samples to draw from the distribution.

# Returns
- `Vector{Float64}`: The samples drawn from the distribution.
"""
function yang_mills_boltzmann(
    only_partial_value::Int,
    edge_sign::Int,
    β::Float64;
    n_samples::Int=1,
    n::Int=2
)::Vector{Int}

    # Calculate unnormalized probabilities for m = 0, 1, ..., n-1
    probs = [exp(β * cos(2π * (only_partial_value + edge_sign * m) / n)) for m in 0:n-1]

    # Normalize the probabilities to sum to 1
    normalized_probs = probs / sum(probs)

    # Use StatsBase for weighted sampling
    items = 0:n-1
    weights = Weights(normalized_probs)

    # Sample from the items using the weighted probabilities
    samples = [StatsBase.sample(items, weights) for _ in 1:n_samples]

    return samples
end

main = false

if main
    using GLMakie

    n = 2  # Number of discrete outcomes (e.g., Bernoulli n=2)
    samples = yang_mills_boltzmann(0, 0, 1, 0.5, n_samples=10^6, n=n)

    # Create a histogram for the discrete values 0 and 1 (or 0 to n-1)
    # The `bins` array must include bin edges that capture discrete values correctly
    hist(samples, bins=0:n, normalization=:pdf)
end