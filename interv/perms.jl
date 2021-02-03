const VT = Vector{T} where T
const VVT = Vector{Vector{T}} where T


function perms(s::VT{T}) where T
  length(s) == 0 && return VVT{T}([[]])
  length(s) == 1 && return VVT{T}([s])
  length(s) == 2 && return VVT{T}([s, reverse(s)])

  ts = VVT{T}([])
  for e ∈ s
    ss = yadiff(s, e) |>
      s_ -> perms(s_) |>
      s_ -> consall(e, s_)

    push!(ts, ss...)
  end
  return ts
end

yadiff(s::VT{T}, e::T) where T = filter(x -> x != e, s)

"""
cons(1, ((2, 3), (2, 4) (3, 4)))
≡ ((1, 2, 3), (1, 2, 4) (1, 3, 4))
"""
function consall(e::T, sos::VVT{T}) where T
  VVT{T}(
         [push!(s, e) for s ∈ sos]
         )
end
