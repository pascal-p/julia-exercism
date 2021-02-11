"""
to be a triangle, a triplet must satisfies the triangle inequality,  which states that:
for any triangle, the sum of the lengths of any two sides must be greater than or equal to the length of the remaining side

If x, y, and z are the lengths of the sides of the triangle, with no side being greater than z, then the triangle inequality states that
z ≤ x + y
"""

struct Triangle{T <: Number}
  x::T
  y::T
  z::T

  function Triangle{T}(;x::T, y::T=x, z::T=x) where {T <: Number}
    z₀ = zero(T)
    if x > z₀ && y > z₀ && z > z₀ && istriangle((x, y, z))
      new(x, y, z)
    else
      throw(ArgumentError("Not a triangle"))
    end
  end
end

function equilateral(t::Triangle{T}) where {T <: Number}
  t.x == t.y == t.z
end

function isosceles(t::Triangle{T}) where {T <: Number}
  any(t -> t[1] == t[2], all_pairs(t))
end

function scalene(t::Triangle{T}) where {T <: Number}
  all(t -> t[1] != t[2], all_pairs(t))
end

for fn in (:equilateral, :isosceles, :scalene)
  @eval begin
    function $(fn)(t::Tuple{T, T, T}) where {T <: Number}
      (x, y, z) = t
      DT = typeof(x)
      try
        tri = Triangle{DT}(;x, y, z)
        $(fn)(tri)

      catch ArgumentError
        false
      end
    end
  end
end


##
## Private Helpers
##

function istriangle(t::Tuple{T, T, T})::Bool where {T <: Number}
  """
  include degenerate triangle, for which we have (for ex.) x + y = z
  """
  (x, y, z) = t
  if z == maximum(t)
    z ≤ x + y
  elseif y == maximum(t)
    y ≤ x + z
  else
    x ≤ y + z
  end
end

function all_pairs(t::Triangle{T})::Vector{Tuple{T, T}} where {T <: Number}
  fn = (fieldnames ∘ typeof)(t)
  # [(s, t) for s in fn, t in filter(x -> x != t, fn) if s != t]

  pairs = Vector{Tuple{Symbol, Symbol}}(undef, length(fn))
  ix = 1
  for u in fn, v in filter(x -> x != u, fn)
    if ix == 1
      pairs[ix] = (u, v)
      ix += 1
    elseif (u, v) ∉ pairs[1:ix-1] && (v, u) ∉ pairs[1:ix-1]
      pairs[ix] = (u, v)
      ix += 1
    end
  end

  map(((x, y)=tup) -> (getfield(t, x), getfield(t, y)), pairs)
end
