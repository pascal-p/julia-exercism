"""
  Abstract Edge Weighted Directed Graph
"""

abstract type AEWDiGraph{T <: Integer, T1 <: Real}; end

v(::AEWDiGraph) = throw(ArgumentError("must be implemented in concrete subtype"))
e(::AEWDiGraph) = throw(ArgumentError("must be implemented in concrete subtype"))

function adj(::AEWDiGraph{T, T1}, ::T) where {T <: Integer, T1 <: Real}
  throw(ArgumentError("must be implemented in concrete subtype"))
end

function has_edge(::AEWDiGraph{T, T1}, ::T, ::T) where {T <: Integer, T1 <: Real}
  throw(ArgumentError("must be implemented in concrete subtype"))
end

function has_weighted_edge(::AEWDiGraph, ::T, ::T) where {T <: Integer}
  throw(ArgumentError("must be implemented in concrete subtype"))
end

function weight(::AEWDiGraph{T, T1}, ::T, ::T) where {T <: Integer, T1 <: Real}
  throw(ArgumentError("must be implemented in concrete subtype"))
end

"""
  Given an empty graph with v vertex, add edges as specified by array  
"""
function build_graph!(::AEWDiGraph{T, T1}, _edges::Vector{Tuple{T, T, T1}}) where {T <: Integer, T1 <: Real}
  throw(ArgumentError("must be implemented in concrete subtype"))
end
