push!(LOAD_PATH, "./src")
using YA_EWD

"""
  Floyd-Warshall All Pairs Shortest Paths [APSP]

  Input:
    - a directed graph G = (V, E) in adjacency-list or adjacency-matrix representation, and
    - a real-valued length lₑ for each edge e ∈ E.

  Output:
    - dist(v, w) ∀ vertex pair (v, w) ∈ V, or a declaration that G contains a negative cycle.
"""

function shortest_path(infile::String;
                       VType::DataType=Int, WType::DataType=Int, positive_weight=true)
  g = EWDiGraph{VType, WType}(infile; positive_weight)
  (shortest_path(g), g)
end

function shortest_path(g::EWDiGraph{T, T1}) where {T, T1 <: Real}
  n = v(g)
  a = Array{T1, 3}(undef, n, n, n)
  a₀ = Array{T1, 2}(undef, n, n)

  ## base case k ≡ 1
  for v in 1:n, w in 1:n
    if v == w
      a₀[v, w] = zero(T1)
    else
      (edge_vw, weight_vw) = has_weighted_edge(g, v, w)
      a₀[v, w] = edge_vw ? weight_vw : infinity(T1)
    end
  end

  ## systematically solve all subproblems
  k = 1
  for v in 1:n, w in 1:n
    v₁, v₂ = a₀[v, k], a₀[k, w]
    a[k, v, w] = if v₁ ≠ infinity(T1) && v₂ ≠ infinity(T1)
      min(a₀[v, w],  v₁ + v₂)
    else
      a₀[v, w]
    end
  end

  for k in 2:n, v in 1:n, w in 1:n
    v₁, v₂ = a[k - 1, v, k], a[k - 1, k, w]
    a[k, v, w] = if v₁ ≠ infinity(T1)  && v₂ ≠ infinity(T1)
      min(a[k - 1, v, w],  v₁ + v₂)
    else
      a[k - 1, v, w]
    end
  end

  ## Check for negative cycles
  for v in 1:n
    a[n, v, v] < 0 && (return :negative_cycle)
  end

  return a[n, 1:end, 1:end]   ##  a[n, v, w] ∀ (v, w) ∈ V
end

infinity(::Type{Int}) = typemax(Int)
infinity(::Type{Float32}) = typemax(Float32)
infinity(::Type{Float64}) = typemax(Float64)
