"""
Custom set implementation

"""

const ∩ = intersect

import Base: ==, ≠, ∈, ∉, intersect, intersect!
import Base: iterate, isempty, length, keys, issubset, push!


struct CustomSet{T} <: AbstractSet{T}
  hsh::Dict{T, Nothing}

  # build empty set
  CustomSet{T}() where {T} = new(Dict{T, Nothing}())

  # build set given a set
  CustomSet{T}(s::CustomSet{T}) where {T} = new(Dict{T, Nothing}(s.hsh))
end

function CustomSet(ary::Vector{T}) where {T}
  isempty(ary) && return CustomSet{T}()

  s = CustomSet{T}()
  for elt in ary
    s.hsh[elt] = nothing
  end

  return s
end

iterate(s::CustomSet{T}, ix...) where {T} = iterate(keys(s.hsh), ix...)

isempty(s::CustomSet{T}) where {T} = iszero(length(s.hsh))

length(s::CustomSet{T}) where {T} = length(s.hsh)

∈(elt::T, s::CustomSet{T}) where {T} = haskey(s.hsh, elt)

keys(s::CustomSet{T}) where {T} = keys(s.hsh)

function ==(s₁::CustomSet{T}, s₂::CustomSet{T}) where {T}
  isempty(s₁) && isempty(s₂) && return true

  length(s₁) == length(s₂) && (sort ∘ collect ∘ keys)(s₁) == (sort ∘ collect ∘ keys)(s₂)
end

function issubset(s₁::CustomSet{T}, s₂::CustomSet{T}) where {T}
  isempty(s₁) && return true
  length(s₁) > length(s₂) && return false

  for elt in s₁ # using iterator vs collect(keys(s₁.hsh))
    elt ∉ s₂ && return false
  end

  return true
end

function disjoint(s₁::CustomSet{T}, s₂::CustomSet{T}) where {T}
  isempty(s₁) && return true
  length(s₁) > 0 && isempty(s₂) && return false

  for elt in s₁ # using iterator vs collect(keys(s₁.hsh))
    elt ∈ s₂ && return false
  end

  return true
end

disjoint(s::CustomSet{Any}, ::CustomSet{T}) where {T} = isempty(s)
disjoint(::CustomSet{T}, s::CustomSet{Any}) where {T} = isempty(s)
disjoint(s₁::CustomSet{Any}, s₂::CustomSet{Any}) = isempty(s₁) && isempty(s₂)

push!(s::CustomSet{T}, elt::T) where {T} = s.hsh[elt] = nothing

add(s::CustomSet{T}, elt::T) where {T} = s.hsh[elt] = nothing

copy(s::CustomSet{T}) where {T} = CustomSet{T}(s)


function intersect(s₁::CustomSet{T1}, s₂::CustomSet{T2}) where {T1 <: Any, T2 <: Any}
  isempty(s₁) && return s₁
  isempty(s₂) && return s₂

  s = CustomSet{typejoin(T1, T2)}()
  s₁, s₂ = length(s₁) > length(s₂) ? (s₁, s₂) : (s₂, s₁)
  for elt in s₁  # using iterator # collect(keys(s₁))
    elt ∈ s₂ && add(s, elt)
  end

  return s
end


function intersect!(s₁::CustomSet{T1}, s₂::CustomSet{T2}) where {T1 <: Any, T2 <: Any}
  isempty(s₁) && return

  if isempty(s₂)
    for elt in collect(keys(s₁)) # side-effect s₁
      delete!(s₁.hsh, elt)
    end
    return
  end

  # finally
  for elt in s₁
    elt ∉ s₂ && delete!(s₁.hsh, elt)
  end
  return
end

function complement(s₁::CustomSet{T1}, s₂::CustomSet{T2}) where {T1 <: Any, T2 <: Any}
  isempty(s₁) && return s₁
  isempty(s₂) && return s₁

  s = CustomSet{typejoin(T1, T2)}()
  for elt in s₁
    elt ∉ s₂ && add(s, elt)
  end

  return s
end

function complement!(s₁::CustomSet{T1}, s₂::CustomSet{T2}) where {T1 <: Any, T2 <: Any}
  isempty(s₁) && return
  isempty(s₂) && return

  for elt in s₁
    elt ∈ s₂ && delete!(s₁.hsh, elt)
  end
  return
end


function union(s₁::CustomSet{T1}, s₂::CustomSet{T2}) where {T1 <: Any, T2 <: Any}
  isempty(s₁) && return s₂
  isempty(s₂) && return s₁

  s₁, s₂ = length(s₁) > length(s₂) ? (s₁, s₂) : (s₂, s₁)
  T = typejoin(T1, T2)
  s = CustomSet{T}(s₂)
  for elt in s₁; add(s, T(elt)); end

  return s
end

function union!(s₁::CustomSet{T1}, s₂::CustomSet{T2}) where {T1 <: Any, T2 <: Any}
  isempty(s₂) && return s₁

  if isempty(s₁)
    for elt in s₂; add(s₁, elt); end
    return
  end

  for elt in s₂; add(s₁, elt); end
  return
end


function show(io::IO, s::CustomSet)
  if isempty(s)
    if get(io, :typeinfo, Any) == typeof(s)
      print(io, "CustomSet()")
    else
      show(io, typeof(s))
      print(io, "()")
    end
  else
    print(io, "CustomSet(")
    show_vector(io, s)
    print(io, ')')
  end
end
