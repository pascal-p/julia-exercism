const VT = Vector{T} where T
const VVT = Vector{Vector{T}} where T

const ST = Set{T} where T
const SST = Set{Set{T}} where T


##
## With Array
##

function all_subset(s::VT{T}) where T
  ns = VVT{T}([])
  for ix ∈ 0:length(s)
    ns = push!(ns, subset_len(s, ix)...)
    # println("==> ns: $(ns) / length: $(ix)")
  end
  return ns
end

function subset_len(s::VT{T}, n) where T
  n == 0 && return VVT{T}([[]])
  n == 1 && return VVT{T}([[e] for e ∈ s])

  # n > 1
  ns = VVT{T}([])
  for e in s
    ss = consall(e,
                 subset_len(yadiff(s, e), n - 1))

    for es ∈ ss
      sort!(es)
      es ∉ ns && push!(ns, es)
    end
  end

  return ns
end


##
## With Set
##

function all_subset(s::ST{T}) where T
  ns = SST{T}([])

  for ix ∈ 0:length(s)
    ns = union(ns, subset_len(s, ix))
    # println("==> ns: $(ns) / length: $(ix)")
  end

  return ns
end

function subset_len(s::ST{T}, n::Int) where T
  n == 0 && return SST{T}([ST{T}([])])
  n == 1 && return SST{T}([ST{T}([e]) for e ∈ s])

  # n > 1
  ns = SST{T}([])
  for e in s
    ss = consall(e,
                 subset_len(yadiff(s, e), n - 1))

    ns = union(ns, ss)
  end

  return ns
end


##
## Helpers Array / Set functions
##

function yadiff(s::VT{T}, e::T) where T
  filter(x -> x != e, s)
end

function yadiff(s::ST{T}, e::T) where T
  setdiff(s, ST{T}([e]))
end

function consall(e::T, sos::VVT{T}) where T
  VVT{T}(
    [push!(s, e) for s ∈ sos]
  )
end

function consall(e::T, sos::SST{T}) where T
  SST{T}(
    [push!(s, e) for s ∈ sos]
  )
end
