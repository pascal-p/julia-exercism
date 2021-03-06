"""
  Abstract Edge Weighted Directed Graph
"""

abstract type AEWDiGraph{T <: Integer, T1 <: Real}; end

v(g::AEWDiGraph) = throw(ArgumentError("must be implemented in concrete subtype"))
e(g::AEWDiGraph) = throw(ArgumentError("must be implemented in concrete subtype"))

function adj(g::AEWDiGraph{T, T1}, u::T) where {T <: Integer, T1 <: Real}
  throw(ArgumentError("must be implemented in concrete subtype"))
end

function has_edge(g::AEWDiGraph{T, T1}, u::T, v::T) where {T <: Integer, T1 <: Real}
  throw(ArgumentError("must be implemented in concrete subtype"))
end

function has_weighted_edge(g::AEWDiGraph, u::T, v::T) where {T <: Integer, T1 <: Real}
  throw(ArgumentError("must be implemented in concrete subtype"))
end

function weight(g::AEWDiGraph{T, T1}, u::T, v::T) where {T <: Integer, T1 <: Real}
  throw(ArgumentError("must be implemented in concrete subtype"))
end

"""
  Given an empty graph with v vertex, add edges as specified by array  
"""
function build_graph!(g::AEWDiGraph{T, T1}, edges::Vector{Tuple{T, T, T1}}) where {T <: Integer, T1 <: Real}
  throw(ArgumentError("must be implemented in concrete subtype"))
end
